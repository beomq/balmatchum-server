#!/usr/bin/env bash
# File-only input. Never enable tracing or print CLI responses.
set +x
set -euo pipefail
umask 077

mode=upload
case "${1:-}" in
  --dry-run) mode=dry-run; shift ;;
  --generate-local) mode=generate-local; shift ;;
esac
if [[ $# != 1 || ! -d "$1" ]]; then
  printf 'Usage: bash set_passwords.sh [--dry-run|--generate-local] DIRECTORY\n' >&2
  exit 2
fi
directory=$(cd -- "$1" && pwd -P)
# Ignore inherited Git context; inspect the physical directory and its parents.
if (unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR GIT_CEILING_DIRECTORIES;
    GIT_MASTER=1 git -C "$directory" rev-parse --show-toplevel >/dev/null 2>&1); then
  printf 'Refused: directory is inside a Git work tree\n' >&2
  exit 2
fi

# Authoritative inventory: group:key. All except optional are required for upload.
entries=(
  session:serverSideSessionKeyHashPepper
  kakao:kakaoAudience
  kakao:kakaoIssuer
  naver:naverClientId
  naver:naverClientSecret
  naver:naverRedirectUri
  google:googleClientSecret
  apple:appleServiceIdentifier
  apple:appleBundleIdentifier
  apple:appleRedirectUri
  apple:appleTeamId
  apple:appleKeyId
  apple:appleKey
  optional:appleAndroidPackageIdentifier
  optional:appleWebRedirectUri
  billing:billingIdentityHmacKey
  billingApple:billingAppleBundleId
  billingApple:billingAppleIssuerId
  billingApple:billingAppleKeyId
  billingApple:billingApplePrivateKey
  billingApple:billingAppleEnvironment
  billingApple:billingAppleProducts
  billingGoogle:billingGooglePackageName
  billingGoogle:billingGoogleClientEmail
  billingGoogle:billingGoogleKeyId
  billingGoogle:billingGooglePrivateKey
  billingGoogle:billingGoogleEnvironment
  billingGoogle:billingGoogleProducts
  # JSON per purpose: {"adUnits":{"ios":"ca-app-pub-.../...","android":"ca-app-pub-.../..."},
  # "rewardItem":"...","rewardAmount":"..."}. The server validates it at startup;
  # see docs/OPERATIONS.md (AdMob section) for the exact shape.
  admob:admobPlacements
)

for entry in "${entries[@]}"; do
  key=${entry#*:}
  file=$directory/$key
  if [[ -L "$file" || ( -e "$file" && ! -f "$file" ) ]]; then
    printf '%s: refused non-regular file\n' "$key" >&2
    exit 2
  fi
done

if [[ "$mode" == generate-local ]]; then
  for entry in "${entries[@]}"; do
    key=${entry#*:}
    case "${entry%%:*}" in
      session) bytes=48 ;;
      billing) bytes=32 ;;
      *) continue ;;
    esac
    file=$directory/$key
    if [[ ! -e "$file" ]]; then
      # noclobber also prevents overwriting a file created after the check.
      (set -o noclobber; openssl rand -base64 "$bytes" > "$file")
      chmod 600 "$file"
    fi
  done
  exit 0
fi

complete=true
for entry in "${entries[@]}"; do
  key=${entry#*:}
  if [[ -s "$directory/$key" && -r "$directory/$key" ]]; then
    [[ "$mode" != dry-run ]] || printf '%s SET\n' "$key"
  else
    [[ "${entry%%:*}" == optional ]] || complete=false
    [[ "$mode" != dry-run ]] || printf '%s MISSING\n' "$key"
  fi
done

# Validate every bundle before the first external write.
for group in naver apple billingApple billingGoogle admob; do
  total=0
  present=0
  for entry in "${entries[@]}"; do
    [[ "${entry%%:*}" == "$group" ]] || continue
    total=$((total + 1))
    key=${entry#*:}
    if [[ -s "$directory/$key" && -r "$directory/$key" ]]; then
      present=$((present + 1))
    fi
  done
  if (( present > 0 && present < total )); then
    printf 'Incomplete bundle: %s\n' "$group" >&2
    exit 2
  fi
done
[[ "$mode" != dry-run ]] || exit 0
if [[ "$complete" != true ]]; then
  printf 'Missing required files; run --dry-run first\n' >&2
  exit 2
fi

if command -v scloud >/dev/null 2>&1; then
  cli=(scloud)
elif command -v serverpod >/dev/null 2>&1; then
  cli=(serverpod cloud)
else
  printf 'Missing scloud or serverpod CLI\n' >&2
  exit 2
fi
# https://docs.serverpod.dev/cloud/concepts/passwords-secrets-env-vars
# https://docs.serverpod.dev/cloud/reference/cli/commands/password
for entry in "${entries[@]}"; do
  key=${entry#*:}
  [[ -s "$directory/$key" && -r "$directory/$key" ]] || continue
  if ! "${cli[@]}" password set --project balmatchum-prod \
      --name "$key" --from-file "$directory/$key" >/dev/null 2>&1; then
    printf '%s: upload failed (CLI output suppressed)\n' "$key" >&2
    exit 1
  fi
  printf '%s SET\n' "$key"
done
