import 'package:serverpod/serverpod.dart';

/// Serverpod 4.0.3 returns passwords verbatim from `config/passwords.yaml` and
/// `SERVERPOD_PASSWORD_*`, and `scloud password set --from-file` uploads a
/// file's final newline. Configuration reads trim once here so identifiers,
/// PEM, JSON and base64 behave like the clean value. Blank stays blank, so
/// each consumer's missing/invalid handling is unchanged.
extension ConfigPassword on Serverpod {
  String? configPassword(String name) => getPassword(name)?.trim();
}
