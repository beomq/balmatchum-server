import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Public, disposable test-only RSA material. Never use in a deployed server.
class KakaoTestKeys {
  static const kid = 'local-kakao-test';
  static final privateKey = RSAPrivateKey(_privatePem);
  static final publicKey = RSAPublicKey(_publicPem);

  static Map<String, dynamic> jwks() => {
    'keys': [publicKey.toJWK(keyID: kid, algorithm: JWTAlgorithm.RS256)],
  };

  static String sign(
    Map<String, dynamic> claims, {
    Map<String, dynamic>? header,
    JWTAlgorithm algorithm = JWTAlgorithm.RS256,
    JWTKey? key,
  }) => JWT(
    Map<String, dynamic>.from(claims),
    header: {'kid': kid, ...?header},
  ).sign(key ?? privateKey, algorithm: algorithm, noIssueAt: true);

  static const _privatePem = '''
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC5eEV8Ht5QUVyD
1sYmOolNCJyHaMOwACf/tCQNQGhsra05/7tYUvNn2YCD2IiK4PR9Clh9htVvQ+Ai
zviNh6Woh/4GTafZBwU7IKpaCfoAl3xBVKjEGj3oXCf4ol2zL6LnqqljrUxoJlNh
YjmHlC/Px+1sjqP5qn9mA4wh8Beig4z2In/5vCKdhEVIjX3063KEhmoX/8WXu3uX
oNy47GP88FRz7YMOoWmCPmI/0qnQ+xoqn2DeNNKPiqPIETFhH3BiOf4PUV/gzR6l
7EFTm/pVpWdcyTUU46pFCa+6aIXdGXVdJKlYnr7ffJCDJoCc5OaUqww1y//mL5pE
su6a/0DjAgMBAAECggEAGxGnqobi0XwecYt+HgQ7F8gi+ExdCynqrJJBFMIKu5nZ
h3aAhFKO/eArtpJ60zIj3MAOzDtKmVOhudLVSeq7Tc6TT54z2iQBKnEJC90a5M03
MF3Hx99Am9Ifb1VbMZTJROCOmmKnnSfC0ZrBZL1HAR9f0pE682xj7aKk6Csfd/NV
jPQLFSr0+fONbaIrPowNn4fSuHXkSdFz9As59yvji773tJMnNsdA70TAmHuxnEmi
vSmeXU8B9w6YJPgpKG8Wuv9BjCLdvRH3l8VvtgOuWoU1H/wVYvgw/kpIiwgb33bl
FHkWgIxaksaByVLQP0TsIQtxuGyhJSWt5UJr9AivaQKBgQDjUzDxxSd+dd+khOvo
BkkIVI+36qUWhDtM8oe34hLwf9kqfOPOjjZy7ukuesLp2rLsJGnWJMx7nJJ1fPJ9
y8LDchs9x/VWFmxNtHdqDgiffydTN6M6qGQTipRjRvSi9wYvYcRw7FlOMUp/o5rJ
NP/PQGB28y1O/taUdYGDZAWL/QKBgQDQ3XzjoZcgXsNljoPTvQhGY0/ysrsYbZG+
5BHWRopez0UNclFbzoe3Neg/pZQ6+JO8Cm2nBBi8RtxCpVxc56fMYjdpxCZuzO29
K+HJBWlFhzOoJW/q+rwhaGRBGDIn6Is3VQE8GXCUs6BmXN3eDRsk7SdCsjDO/iD6
KyWAxkfmXwKBgD+KzoCWOn7n1fa3zPVTZHC2qmGfbjwIBEdy96rXv7GIGxz8QfVH
3UJtM7LxT7BsmFzXpNnd+WaIEoxSu7mcDjnxmFnBnftNU0K5MjPr7k8fDM//GlpY
HXk04FuLxvASmqD99BoYhrILpyZchfS+Is880HoPaVfOdg6TdftTJxXFAoGAELCy
Sypdfju0V4g05pWjdKR4/gbkRoZy8BMfjcTjR8I+XV22PKTbWXuYTIW5u6CjhZI7
wu3j4B+1eCnooI/ua7mpfe0ruQztLoG0MDEbgW/VY+lh8SAKKo1B/aWmVGQTw98q
ExhhU7Cq76MaI6VeduvwiDbfCZtrHTKXc5vkoPcCgYB4yTIzTIe967szS0cblDMO
yOY+kHS2jzNqJ2d4mi9xzbncypPmj734KY+eoOmQVAOd2RRi7pX/6rwuyEUYtvwr
ljIV9zB2nuk3u4YZxwSof7V+y3aDNbnoZ8vnVc3hVx0TN2V/kU3JQtYjds6SvrTf
1lnwM51nOK4hEn9/x2zqsA==
-----END PRIVATE KEY-----
''';
  static const _publicPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuXhFfB7eUFFcg9bGJjqJ
TQich2jDsAAn/7QkDUBobK2tOf+7WFLzZ9mAg9iIiuD0fQpYfYbVb0PgIs74jYel
qIf+Bk2n2QcFOyCqWgn6AJd8QVSoxBo96Fwn+KJdsy+i56qpY61MaCZTYWI5h5Qv
z8ftbI6j+ap/ZgOMIfAXooOM9iJ/+bwinYRFSI199OtyhIZqF//Fl7t7l6DcuOxj
/PBUc+2DDqFpgj5iP9Kp0PsaKp9g3jTSj4qjyBExYR9wYjn+D1Ff4M0epexBU5v6
VaVnXMk1FOOqRQmvumiF3Rl1XSSpWJ6+33yQgyaAnOTmlKsMNcv/5i+aRLLumv9A
4wIDAQAB
-----END PUBLIC KEY-----
''';
}
