part of 'billing_verifier.dart';

/// Optional per-store groups. A supplied but incomplete group is a startup error.
/// No fallback app identifiers, products, environment or credentials are inferred.
final class BillingConfig {
  BillingConfig._(this.apple, this.google);
  final AppleBillingConfig? apple;
  final GoogleBillingConfig? google;

  factory BillingConfig.fromPasswords(String? Function(String) password) {
    try {
      Map<String, String>? group(String prefix, List<String> names) {
        final values = {for (final n in names) n: password('$prefix$n')};
        if (values.values.every((v) => v == null)) return null;
        if (values.values.any((v) => v == null || v.trim().isEmpty)) {
          throw const FormatException();
        }
        return values.map((k, v) => MapEntry(k, v!));
      }

      BillingEnvironment environment(String value) => switch (value) {
        'production' => BillingEnvironment.production,
        'sandbox' => BillingEnvironment.sandbox,
        _ => throw const FormatException(),
      };
      Map<String, BillingProductKind> products(String value) {
        final json = _object(jsonDecode(value));
        if (json.isEmpty || json.length > 20) {
          throw const FormatException();
        }
        return Map.unmodifiable(
          json.map((id, kind) {
            if (!RegExp(r'^[A-Za-z0-9._-]{1,200}$').hasMatch(id)) {
              throw const FormatException();
            }
            return MapEntry(id, switch (kind) {
              'subscription' => BillingProductKind.subscription,
              'lifetime' => BillingProductKind.lifetime,
              _ => throw const FormatException(),
            });
          }),
        );
      }

      final a = group('billingApple', [
        'BundleId',
        'IssuerId',
        'KeyId',
        'PrivateKey',
        'Environment',
        'Products',
      ]);
      final g = group('billingGoogle', [
        'PackageName',
        'ClientEmail',
        'KeyId',
        'PrivateKey',
        'Environment',
        'Products',
      ]);
      AppleBillingConfig? apple;
      GoogleBillingConfig? google;
      if (a != null) {
        final key = ECPrivateKey(a['PrivateKey']!);
        if (key.size != 32 ||
            key.key.parameters?.domainName != 'prime256v1' ||
            !RegExp(r'^[A-Za-z0-9.-]{3,255}$').hasMatch(a['BundleId']!)) {
          throw const FormatException();
        }
        apple = AppleBillingConfig._(
          a['BundleId']!,
          a['IssuerId']!,
          a['KeyId']!,
          key,
          environment(a['Environment']!),
          products(a['Products']!),
        );
      }
      if (g != null) {
        final key = RSAPrivateKey(g['PrivateKey']!);
        if (key.key.modulus!.bitLength < 2048 ||
            !RegExp(
              r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$',
            ).hasMatch(g['PackageName']!) ||
            !RegExp(
              r'^[^\s@]+@[^\s@]+\.gserviceaccount\.com$',
            ).hasMatch(g['ClientEmail']!)) {
          throw const FormatException();
        }
        google = GoogleBillingConfig._(
          g['PackageName']!,
          g['ClientEmail']!,
          g['KeyId']!,
          key,
          environment(g['Environment']!),
          products(g['Products']!),
        );
      }
      return BillingConfig._(apple, google);
    } catch (_) {
      throw const BillingVerificationException(BillingFailure.configuration);
    }
  }
}

final class AppleBillingConfig {
  AppleBillingConfig._(
    this.bundleId,
    this.issuerId,
    this.keyId,
    this._key,
    this.environment,
    this.products,
  );
  final String bundleId;
  final String issuerId;
  final String keyId;
  final ECPrivateKey _key;
  final BillingEnvironment environment;
  final Map<String, BillingProductKind> products;
}

final class GoogleBillingConfig {
  GoogleBillingConfig._(
    this.packageName,
    this.clientEmail,
    this.keyId,
    this._key,
    this.environment,
    this.products,
  );
  final String packageName;
  final String clientEmail;
  final String keyId;
  final RSAPrivateKey _key;
  final BillingEnvironment environment;
  final Map<String, BillingProductKind> products;
}
