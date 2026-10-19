part of 'billing_verifier.dart';

enum BillingStore { apple, google }

enum BillingEnvironment { production, sandbox }

enum BillingProductKind { subscription, lifetime }

enum BillingState {
  active,
  grace,
  expired,
  pending,
  onHold,
  paused,
  billingRetry,
  revoked,
}

enum BillingFailure { configuration, invalidPurchase, unavailable }

/// Intentionally contains no request URI, credential, token or upstream body.
final class BillingVerificationException implements Exception {
  const BillingVerificationException(this.code);
  final BillingFailure code;
  @override
  String toString() => 'BillingVerificationException(${code.name})';
}

/// An observation, NOT a persisted entitlement or proof of current account existence.
final class BillingFacts {
  const BillingFacts._({
    required this.store,
    required this.environment,
    required this.productId,
    required this.kind,
    required this.ownerBinding,
    required this.purchaseReference,
    required this.transactionId,
    required this.state,
    required this.observedAt,
    required this.purchasedAt,
    required this.expiresAt,
    required this.graceExpiresAt,
    required this.revokedAt,
  });
  final BillingStore store;
  final BillingEnvironment environment;
  final String productId;
  final BillingProductKind kind;
  final String ownerBinding;

  /// Apple original transaction ID or Google purchase token; never log this.
  final String purchaseReference;

  /// Apple transaction ID or Google latest successful order ID, if present.
  final String? transactionId;
  final BillingState state;
  final DateTime observedAt;
  final DateTime? purchasedAt;
  final DateTime? expiresAt;
  final DateTime? graceExpiresAt;
  final DateTime? revokedAt;

  /// Exclusive end boundary, without invented billing-retry or cache extensions.
  /// Callers must re-query before consuming benefits, even for lifetime purchases.
  bool isActiveAt(DateTime instant) {
    if (instant.isBefore(observedAt) ||
        purchasedAt == null ||
        instant.isBefore(purchasedAt!) ||
        revokedAt != null) {
      return false;
    }
    if (state == BillingState.grace) {
      return graceExpiresAt != null && instant.isBefore(graceExpiresAt!);
    }
    if (state != BillingState.active) return false;
    return kind == BillingProductKind.lifetime ||
        (expiresAt != null && instant.isBefore(expiresAt!));
  }
}

Never _invalid() =>
    throw const BillingVerificationException(BillingFailure.invalidPurchase);
Map<String, dynamic> _object(Object? value) {
  if (value is! Map<String, dynamic>) {
    _invalid();
  }
  return value;
}

String _string(Object? value) {
  if (value is! String || value.isEmpty || value.length > 8192) {
    _invalid();
  }
  return value;
}

DateTime _millis(Object? value) {
  if (value is! int || value < 0 || value > 253402300799999) {
    _invalid();
  }
  return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
}

DateTime? _optionalMillis(Map<String, dynamic> value, String key) =>
    value.containsKey(key) ? _millis(value[key]) : null;
DateTime _timestamp(Object? value) {
  final text = _string(value);
  // DateTime.parse alone accepts missing zones and normalizes impossible dates.
  if (!RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,9})?Z$',
  ).hasMatch(text)) {
    _invalid();
  }
  final time = DateTime.tryParse(text);
  if (time == null ||
      time.toUtc().toIso8601String().substring(0, 19) !=
          text.substring(0, 19)) {
    _invalid();
  }
  return time.toUtc();
}

void _lookup(String key, String owner) {
  if (key.isEmpty ||
      key.length > 4096 ||
      owner.isEmpty ||
      owner.length > 128 ||
      key.codeUnits.any((c) => c <= 32 || c == 127)) {
    _invalid();
  }
}
