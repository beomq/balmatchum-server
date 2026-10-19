import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// dart:io parses request targets through Uri (which normalizes % escapes).
/// Tap the first request line, but leave HTTP framing/parsing to HttpServer.
/// This dedicated listener deliberately allows only one request per connection.
class RawQueryServer {
  RawQueryServer._(this._http, this._sockets);
  final HttpServer _http;
  final _TappedServer _sockets;
  int get port => _sockets.port;

  static Future<RawQueryServer> bind({
    required InternetAddress address,
    required int port,
    required Future<int> Function(String) callback,
  }) async {
    final sockets = _TappedServer(await ServerSocket.bind(address, port));
    final http = HttpServer.listenOn(sockets)
      ..idleTimeout = const Duration(seconds: 10);
    final result = RawQueryServer._(http, sockets);
    http.listen((request) async {
      request.response.persistentConnection = false;
      final info = request.connectionInfo!;
      final key = '${info.remoteAddress.address}:${info.remotePort}';
      final socket = sockets.connections[key];
      var status = 400;
      if (socket != null && !socket.handled) {
        socket.handled = true;
        final line = socket.line;
        final fields = line?.split(' ');
        if (fields != null && fields.length == 3) {
          final target = fields[1];
          final query = target.indexOf('?');
          final path = query < 0 ? target : target.substring(0, query);
          if (path != '/admob/ssv') {
            status = 404;
          } else if (fields[0] != 'GET') {
            status = 405;
          } else if (query >= 0) {
            try {
              status = await callback(target.substring(query + 1));
            } catch (_) {
              status = 503;
            }
          }
        }
      }
      request.response.statusCode = status;
      await request.response.close();
    });
    return result;
  }

  Future<void> close() async {
    await _http.close(force: true);
    for (final socket in _sockets.connections.values.toList()) {
      socket.destroy();
    }
    await _sockets.close();
  }
}

class _TappedServer extends Stream<Socket> implements ServerSocket {
  _TappedServer(this.inner);
  final ServerSocket inner;
  final connections = <String, _TappedSocket>{};
  @override
  int get port => inner.port;
  @override
  InternetAddress get address => inner.address;
  @override
  Future<ServerSocket> close() => inner.close();
  @override
  StreamSubscription<Socket> listen(
    void Function(Socket)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => inner
      .map((socket) {
        final key = '${socket.remoteAddress.address}:${socket.remotePort}';
        final tapped = _TappedSocket(socket, () => connections.remove(key));
        connections[key] = tapped;
        return tapped;
      })
      .listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

class _TappedSocket extends Stream<Uint8List> implements Socket {
  _TappedSocket(this.inner, this.onClosed) {
    _deadline = Timer(const Duration(seconds: 10), destroy);
  }
  final Socket inner;
  final void Function() onClosed;
  late final Timer _deadline;
  final _prefix = <int>[];
  String? line;
  bool handled = false;
  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => inner
      .map((bytes) {
        if (line == null) {
          for (final byte in bytes) {
            _prefix.add(byte);
            if (_prefix.length > 16384) {
              destroy();
              break;
            }
            if (byte == 10) {
              if (_prefix.length > 1 && _prefix[_prefix.length - 2] == 13) {
                line = ascii.decode(_prefix.sublist(0, _prefix.length - 2));
              }
              break;
            }
          }
        }
        return bytes;
      })
      .listen(
        onData,
        onError: onError,
        onDone: () {
          _deadline.cancel();
          onClosed();
          onDone?.call();
        },
        cancelOnError: cancelOnError,
      );
  @override
  void destroy() {
    _deadline.cancel();
    onClosed();
    inner.destroy();
  }

  @override
  Encoding get encoding => inner.encoding;
  @override
  set encoding(Encoding value) => inner.encoding = value;
  @override
  void add(List<int> data) => inner.add(data);
  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      inner.addError(error, stackTrace);
  @override
  Future<void> addStream(Stream<List<int>> stream) => inner.addStream(stream);
  @override
  void write(Object? object) => inner.write(object);
  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      inner.writeAll(objects, separator);
  @override
  void writeCharCode(int charCode) => inner.writeCharCode(charCode);
  @override
  void writeln([Object? object = '']) => inner.writeln(object);
  @override
  Future<void> flush() => inner.flush();
  @override
  Future close() => inner.close();
  @override
  Future get done => inner.done;
  @override
  int get port => inner.port;
  @override
  int get remotePort => inner.remotePort;
  @override
  InternetAddress get address => inner.address;
  @override
  InternetAddress get remoteAddress => inner.remoteAddress;
  @override
  bool setOption(SocketOption option, bool enabled) =>
      inner.setOption(option, enabled);
  @override
  Uint8List getRawOption(RawSocketOption option) => inner.getRawOption(option);
  @override
  void setRawOption(RawSocketOption option) => inner.setRawOption(option);
}
