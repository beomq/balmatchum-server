BEGIN;

--
-- NORMALIZATION-STEP2 SELF-VERIFICATION BEGIN
-- Runs before any ALTER in the same transaction; any RAISE EXCEPTION below
-- rolls the whole migration back and leaves the step-1 schema untouched.
--
-- (1) Re-run the step-1 backfill (idempotent) for rows written between the
--     two rollouts by a server that still wrote only "owner".
UPDATE "ad_intent" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "ad_intent".owner::uuid);
UPDATE "billing_account" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "billing_account".owner::uuid);
UPDATE "billing_purchase" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "billing_purchase".owner::uuid);
UPDATE "dog_profile" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "dog_profile".owner::uuid);
UPDATE "gps_record" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "gps_record".owner::uuid);
UPDATE "outfit_ownership" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "outfit_ownership".owner::uuid);
UPDATE "point_entry" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "point_entry".owner::uuid);
UPDATE "product_account" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_account".owner::uuid);
UPDATE "product_day" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_day".owner::uuid);
UPDATE "product_request" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_request".owner::uuid);
UPDATE "quiz_assignment" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "quiz_assignment".owner::uuid);
UPDATE "quiz_state" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "quiz_state".owner::uuid);
UPDATE "step_revision" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "step_revision".owner::uuid);
UPDATE "theme_ownership" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "theme_ownership".owner::uuid);
UPDATE "gps_record" SET "firstLocalDay" = floor((extract(epoch from (payload->>'startedAt')::timestamptz) + 32400) / 86400)::int, "lastLocalDay" = floor((extract(epoch from (payload->>'endedAt')::timestamptz) + 32400) / 86400)::int WHERE payload IS NOT NULL AND NOT deleted AND "firstLocalDay" IS NULL;
UPDATE "product_request" SET "createdAt" = now() WHERE "createdAt" IS NULL;
UPDATE "product_account" a SET "balance" = COALESCE((SELECT SUM(amount) FROM point_entry e WHERE e.owner = a.owner AND e."policyVersion" IN ('steps-v1-20261019','quiz-v1-20261019','theme-purchase-v1-20261027','outfit-purchase-v1-20261027')),0), "fixtureBalance" = COALESCE((SELECT SUM(amount) FROM point_entry e WHERE e.owner = a.owner AND e."policyVersion" = 'development-fixture-v1-not-production'),0);
-- (2) Billing orphans keep the retention rules of _deleteBillingData before
--     they are deleted: identity tombstone (identityRetainUntil) and the
--     anonymous payment record (paymentRecordOf). GREATEST ignores NULLs.
--     "+ n years" mirrors Dart DateTime.utc(year + n, month, day, ...): the
--     day is added to the 1st of the target month, so Feb 29 rolls over to
--     Mar 1 exactly as in Dart (interval '1 year' would clamp to Feb 28).
INSERT INTO "billing_purchase_tombstone" ("identityHash", "retainUntil")
SELECT p."identityHash", CASE WHEN p.kind = 'lifetime' THEN NULL ELSE make_date(extract(year from b.base)::int + 1, extract(month from b.base)::int, 1) + (extract(day from b.base)::int - 1) * interval '1 day' + (b.base - date_trunc('day', b.base)) END
FROM "billing_purchase" p
CROSS JOIN LATERAL (SELECT COALESCE(GREATEST(p."expiresAt", p."graceExpiresAt"), p."observedAt") AS base) b
WHERE p."authUserId" IS NULL
ON CONFLICT ("identityHash") DO UPDATE SET "retainUntil" = CASE WHEN "billing_purchase_tombstone"."retainUntil" IS NULL OR EXCLUDED."retainUntil" IS NULL THEN NULL ELSE GREATEST("billing_purchase_tombstone"."retainUntil", EXCLUDED."retainUntil") END;
INSERT INTO "billing_payment_record" ("store", "environment", "productId", "kind", "storeTransactionId", "originalTransactionId", "state", "purchasedAt", "expiresAt", "revokedAt", "recordedAt", "purgeAfter")
SELECT p."store", p."environment", p."productId", p."kind", p."transactionId", CASE WHEN p."store" = 'apple' THEN p."purchaseReference" ELSE NULL END, p."state", p."purchasedAt", p."expiresAt", p."revokedAt", (now() AT TIME ZONE 'UTC'), make_date(extract(year from b.base)::int + 5, extract(month from b.base)::int, 1) + (extract(day from b.base)::int - 1) * interval '1 day' + (b.base - date_trunc('day', b.base))
FROM "billing_purchase" p
CROSS JOIN LATERAL (SELECT GREATEST(COALESCE(p."purchasedAt", p."observedAt"), p."revokedAt", CASE WHEN p.kind = 'subscription' THEN (CASE WHEN p."expiresAt" IS NOT NULL AND p."expiresAt" < p."observedAt" THEN p."expiresAt" ELSE p."observedAt" END) END) AS base) b
WHERE p."authUserId" IS NULL;
-- (2c, 2d) Delete orphans whose AuthUser no longer exists; counts go to NOTICE.
DO $$
DECLARE deleted bigint;
BEGIN
  DELETE FROM "billing_purchase" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from billing_purchase', deleted;
  DELETE FROM "billing_account" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from billing_account', deleted;
  DELETE FROM "ad_intent" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from ad_intent', deleted;
  DELETE FROM "dog_profile" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from dog_profile', deleted;
  DELETE FROM "gps_record" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from gps_record', deleted;
  DELETE FROM "outfit_ownership" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from outfit_ownership', deleted;
  DELETE FROM "point_entry" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from point_entry', deleted;
  DELETE FROM "product_account" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from product_account', deleted;
  DELETE FROM "product_day" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from product_day', deleted;
  DELETE FROM "product_request" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from product_request', deleted;
  DELETE FROM "quiz_assignment" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from quiz_assignment', deleted;
  DELETE FROM "quiz_state" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from quiz_state', deleted;
  DELETE FROM "step_revision" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from step_revision', deleted;
  DELETE FROM "theme_ownership" WHERE "authUserId" IS NULL;
  GET DIAGNOSTICS deleted = ROW_COUNT;
  RAISE NOTICE 'normalization-step2: deleted % orphan rows from theme_ownership', deleted;
END $$;
-- (3) Abort the migration if any NULL "authUserId" remains.
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "ad_intent" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: ad_intent has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "billing_account" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: billing_account has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "billing_purchase" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: billing_purchase has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "dog_profile" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: dog_profile has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "gps_record" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: gps_record has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "outfit_ownership" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: outfit_ownership has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "point_entry" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: point_entry has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "product_account" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: product_account has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "product_day" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: product_day has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "product_request" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: product_request has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "quiz_assignment" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: quiz_assignment has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "quiz_state" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: quiz_state has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "step_revision" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: step_revision has NULL authUserId'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM "theme_ownership" WHERE "authUserId" IS NULL) THEN RAISE EXCEPTION 'normalization-step2: theme_ownership has NULL authUserId'; END IF; END $$;
--
-- NORMALIZATION-STEP2 SELF-VERIFICATION END
--
--
-- ACTION ALTER TABLE
--
DROP INDEX "ad_intent_target";
ALTER TABLE "ad_intent" DROP COLUMN "owner";
ALTER TABLE "ad_intent" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "billing_account_owner";
ALTER TABLE "billing_account" DROP COLUMN "owner";
ALTER TABLE "billing_account" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "billing_purchase_owner";
ALTER TABLE "billing_purchase" DROP COLUMN "owner";
ALTER TABLE "billing_purchase" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "dog_profile_owner";
ALTER TABLE "dog_profile" DROP COLUMN "owner";
ALTER TABLE "dog_profile" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "gps_record_owner_client_unique";
ALTER TABLE "gps_record" DROP COLUMN "owner";
ALTER TABLE "gps_record" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "outfit_ownership_key";
ALTER TABLE "outfit_ownership" DROP COLUMN "owner";
ALTER TABLE "outfit_ownership" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "point_entry_key";
ALTER TABLE "point_entry" DROP COLUMN "owner";
ALTER TABLE "point_entry" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "product_account_owner";
ALTER TABLE "product_account" DROP COLUMN "owner";
ALTER TABLE "product_account" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "product_day_owner_date";
ALTER TABLE "product_day" DROP COLUMN "owner";
ALTER TABLE "product_day" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "product_request_key";
ALTER TABLE "product_request" DROP COLUMN "owner";
ALTER TABLE "product_request" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "quiz_assignment_slot";
DROP INDEX "quiz_assignment_seen_question";
ALTER TABLE "quiz_assignment" DROP COLUMN "owner";
ALTER TABLE "quiz_assignment" DROP COLUMN "snapshot";
ALTER TABLE "quiz_assignment" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "quiz_state_key";
ALTER TABLE "quiz_state" DROP COLUMN "owner";
ALTER TABLE "quiz_state" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "step_revision_key";
ALTER TABLE "step_revision" DROP COLUMN "owner";
ALTER TABLE "step_revision" ALTER COLUMN "authUserId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
DROP INDEX "theme_ownership_key";
ALTER TABLE "theme_ownership" DROP COLUMN "owner";
ALTER TABLE "theme_ownership" ALTER COLUMN "authUserId" SET NOT NULL;

--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261031133033603-normalization-step2', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261031133033603-normalization-step2', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();


COMMIT;
