import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';

class AdKeysUnavailable implements Exception {}

/// Kind of a reward-less request (one without custom_data), for logging only.
enum AdPing { signatureValid, signatureInvalid, unsigned, emptyQuery }

class AdEvent {
  AdEvent(
    this.owner,
    this.customData,
    this.unit,
    this.rewardItem,
    this.rewardAmount,
    this.transactionId,
    this.at,
    this.digest,
  );
  final String owner,
      customData,
      unit,
      rewardItem,
      rewardAmount,
      transactionId,
      digest;
  final DateTime at;
}

class AdVerifier {
  AdVerifier({
    Future<Map<String, dynamic>> Function()? loadKeys,
    this.clock = const Clock(),
  }) : loadKeys = loadKeys ?? fetchGoogleKeys;
  final Future<Map<String, dynamic>> Function() loadKeys;
  final Clock clock;
  static const keysUrl =
      'https://www.gstatic.com/admob/reward/verifier-keys.json';
  static const cacheTtl = Duration(hours: 23);
  Map<String, pc.ECPublicKey> _keys = {};
  DateTime? _expires;
  DateTime? _nextRefresh;
  Future<void>? _loading;

  static Future<Map<String, dynamic>> fetchGoogleKeys() async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(keysUrl))
        ..followRedirects = false;
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw AdKeysUnavailable();
      final body = await response.stream.bytesToString().timeout(
        const Duration(seconds: 10),
      );
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  bool get _fresh =>
      _expires != null && clock.now().toUtc().isBefore(_expires!);

  Future<void> _refresh() => _loading ??= _fetch();
  Future<void> _fetch() async {
    try {
      final fetchedAt = clock.now().toUtc();
      final document = await Future.sync(loadKeys);
      final keys = <String, pc.ECPublicKey>{};
      for (final row in document['keys'] as List) {
        final id = (row as Map<String, dynamic>)['keyId'];
        if (id is! int || keys.containsKey('$id')) {
          throw const FormatException();
        }
        final key = jwt.ECPublicKey(row['pem'] as String).key;
        if (key.parameters!.domainName != 'prime256v1' &&
            key.parameters!.domainName != 'secp256r1') {
          throw const FormatException();
        }
        keys['$id'] = key;
      }
      if (keys.isEmpty) throw const FormatException();
      _keys = keys;
      _expires = fetchedAt.add(cacheTtl);
    } catch (_) {
      throw AdKeysUnavailable();
    } finally {
      _loading = null;
    }
  }

  Future<pc.ECPublicKey> _key(String id) async {
    final hadFresh = _fresh;
    if (!hadFresh) await _refresh();
    if (!_keys.containsKey(id) &&
        hadFresh &&
        (_nextRefresh == null ||
            !clock.now().toUtc().isBefore(_nextRefresh!))) {
      _nextRefresh = clock.now().toUtc().add(const Duration(minutes: 1));
      await _refresh();
    }
    if (!_fresh) throw AdKeysUnavailable();
    final key = _keys[id];
    if (key == null) throw const FormatException('Unknown key');
    return key;
  }

  /// Null when the query carries a non-empty custom_data and must go through
  /// [verify]. Otherwise it can grant nothing (e.g. the AdMob console's
  /// "Verify URL" check, whose shape is undocumented), so it is acknowledged
  /// whatever its signature or parameters; the kind is reported for logging.
  Future<AdPing?> ping(String raw) async {
    final parts = raw.split('&');
    if (parts.any((p) => p.startsWith('custom_data=') && p.length > 12)) {
      return null;
    }
    if (raw.isEmpty) return AdPing.emptyQuery;
    if (!_signedTail(parts)) return AdPing.unsigned;
    try {
      await _checkSignature(parts);
      return AdPing.signatureValid;
    } on Exception {
      return AdPing.signatureInvalid;
    }
  }

  static bool _signedTail(List<String> parts) =>
      parts.length >= 3 &&
      parts[parts.length - 2].startsWith('signature=') &&
      RegExp(r'^key_id=[0-9]+$').hasMatch(parts.last);

  Future<AdEvent> verify(String raw) async {
    if (raw.length > 16000 || raw.codeUnits.any((c) => c < 33 || c > 126)) {
      throw const FormatException('Invalid query');
    }
    final parts = raw.split('&');
    if (!_signedTail(parts)) {
      throw const FormatException('Invalid signature placement');
    }
    await _checkSignature(parts);
    final signed = parts.take(parts.length - 2).join('&');
    return _event(parts, signed);
  }

  Future<void> _checkSignature(List<String> parts) async {
    final signed = parts.take(parts.length - 2).join('&');
    final key = await _key(parts.last.substring(7));
    try {
      final signatureText = parts[parts.length - 2].substring(10);
      if (!RegExp(r'^[A-Za-z0-9_-]+={0,2}$').hasMatch(signatureText)) {
        throw const FormatException();
      }
      final bytes = base64Url.decode(base64Url.normalize(signatureText));
      final parser = ASN1Parser(bytes);
      final sequence = parser.nextObject() as ASN1Sequence;
      if (parser.hasNext() || sequence.elements!.length != 2) {
        throw const FormatException();
      }
      final r = (sequence.elements![0] as ASN1Integer).integer!;
      final s = (sequence.elements![1] as ASN1Integer).integer!;
      final canonical = ASN1Sequence(
        elements: [ASN1Integer(r), ASN1Integer(s)],
      ).encode();
      if (base64.encode(canonical) != base64.encode(bytes)) {
        throw const FormatException();
      }
      final verifier = pc.Signer('SHA-256/ECDSA')
        ..init(false, pc.PublicKeyParameter<pc.ECPublicKey>(key));
      if (!verifier.verifySignature(
        Uint8List.fromList(utf8.encode(signed)),
        pc.ECSignature(r, s),
      )) {
        throw const FormatException();
      }
    } catch (_) {
      throw const FormatException('Invalid signature');
    }
  }

  AdEvent _event(List<String> parts, String signed) {
    // Decode only AFTER verification. Reject duplicate/encoded names and unknown
    // fields rather than ambiguously selecting one signed value.
    const names = {
      'ad_network',
      'ad_unit',
      'custom_data',
      'reward_amount',
      'reward_item',
      'timestamp',
      'transaction_id',
      'user_id',
    };
    final values = <String, String>{};
    for (final part in parts.take(parts.length - 2)) {
      final separator = part.indexOf('=');
      if (separator < 1) throw const FormatException('Invalid parameter');
      final name = part.substring(0, separator);
      final encoded = part.substring(separator + 1);
      if (!names.contains(name) ||
          values.containsKey(name) ||
          RegExp(r'%(?![0-9A-Fa-f]{2})').hasMatch(encoded)) {
        throw const FormatException('Invalid parameter');
      }
      values[name] = Uri.decodeQueryComponent(encoded);
    }
    if (values.length != names.length ||
        values.values.any((v) => v.isEmpty) ||
        !RegExp(r'^[0-9]+$').hasMatch(values['timestamp']!) ||
        !RegExp(r'^[0-9]+$').hasMatch(values['reward_amount']!) ||
        !RegExp(r'^[0-9a-fA-F]{1,256}$').hasMatch(values['transaction_id']!) ||
        !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(values['custom_data']!)) {
      throw const FormatException('Invalid metadata');
    }
    final milliseconds = int.tryParse(values['timestamp']!);
    if (milliseconds == null || milliseconds > 8640000000000000) {
      throw const FormatException('Invalid timestamp');
    }
    final at = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    return AdEvent(
      values['user_id']!,
      values['custom_data']!,
      values['ad_unit']!,
      values['reward_item']!,
      values['reward_amount']!,
      values['transaction_id']!,
      at,
      sha256.convert(utf8.encode(signed)).toString(),
    );
  }
}
