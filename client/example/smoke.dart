import 'package:balmatchum_client/balmatchum_client.dart';

/// Run against a local server: dart run example/smoke.dart http://localhost:8080/
Future<void> main(List<String> args) async {
  final client = Client(args.single);
  try {
    final greeting = await client.greeting.hello('Balmatchum');
    if (greeting.message != 'Hello Balmatchum') {
      throw StateError('Unexpected greeting: ${greeting.message}');
    }
    print('CLIENT_SMOKE_OK');
  } finally {
    client.close();
  }
}
