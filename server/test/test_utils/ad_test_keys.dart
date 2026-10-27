import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';

// Public disposable test key pair.
const wrongAdPublicPem = '''
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAExxV1CgNQxgZvQV2SQTzbMaSqByzr
JhJ+Rvx142KG4m6ncZtk4vFqeOLf5PgzsR7lMR/lwWsqzhETrJW1kg6/Gw==
-----END PUBLIC KEY-----
''';
const adPublicPem = '''
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEdM8DhjOgaGgmJUGsgHnZRsATiNJI
8b5dqwJY0X9jDy91ATKUX/Loa9d/dnlr/zxj1WqQ4XWgFVmEwDwPxlZiNQ==
-----END PUBLIC KEY-----
''';
const adPrivatePem = '''
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgkX3TcB+mcl4w74f6
C0llGx7flz9Z5Gci6UD239sQDNShRANCAAR0zwOGM6BoaCYlQayAedlGwBOI0kjx
vl2rAljRf2MPL3UBMpRf8uhr1392eWv/PGPVapDhdaAVWYTAPA/GVmI1
-----END PRIVATE KEY-----
''';
Map<String, dynamic> adKeys() => {
  'keys': [
    {'keyId': 1, 'pem': adPublicPem},
  ],
};
String signAd(String raw, {int keyId = 1}) {
  final signer = pc.Signer('SHA-256/DET-ECDSA')
    ..init(
      true,
      pc.PrivateKeyParameter<pc.ECPrivateKey>(
        jwt.ECPrivateKey(adPrivatePem).key,
      ),
    );
  final signature =
      signer.generateSignature(Uint8List.fromList(utf8.encode(raw)))
          as pc.ECSignature;
  final der = ASN1Sequence(
    elements: [ASN1Integer(signature.r), ASN1Integer(signature.s)],
  ).encode();
  return '$raw&signature=${base64Url.encode(der).replaceAll('=', '')}&key_id=$keyId';
}
