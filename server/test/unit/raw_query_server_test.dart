import 'dart:convert';
import 'dart:io';
import 'package:balmatchum_server/src/ads/raw_query_server.dart';
import 'package:test/test.dart';

void main() {
  test(
    'preserves exact escapes across packets and handles one pipelined request',
    () async {
      final seen = <String>[];
      final server = await RawQueryServer.bind(
        address: InternetAddress.loopbackIPv4,
        port: 0,
        callback: (query) async {
          seen.add(query);
          return 200;
        },
      );
      addTearDown(server.close);
      final socket = await Socket.connect('127.0.0.1', server.port);
      addTearDown(socket.destroy);
      final response = socket.cast<List<int>>().transform(utf8.decoder).join();
      socket.write('GET /admob/ssv?a=%2');
      await socket.flush();
      socket.write(
        'f%63+%20 HTTP/1.1\r\nHost: localhost\r\n\r\n'
        'GET /admob/ssv?a=second HTTP/1.1\r\nHost: localhost\r\n\r\n',
      );
      await socket.flush();
      expect(
        await response.timeout(const Duration(seconds: 5)),
        contains('200 OK'),
      );
      expect(seen, ['a=%2f%63+%20']);
    },
  );
}
