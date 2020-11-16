import 'dart:async';
import 'dart:io';

import 'server_websocket.dart';

abstract class BaseServer {
  final String name;
  final String address;
  final int port;

  HttpServer server;
  StreamSubscription<HttpRequest> sub;

  BaseServer(this.name, this.address, this.port);

  void init() async {
    server = await HttpServer.bind(address, port);
    server.idleTimeout = null;
    sub = server.listen(_onRequest);

    print('$name server started at $address:$port');
  }

  Future<bool> onRequestPre(HttpRequest req) async => false;
  Future<void> onRequestPost(HttpRequest req) async {}

  void _onRequest(HttpRequest req) async {
    final close = await onRequestPre(req);

    if (close) {
      return;
    }

    // handle websocket connection
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final socket = ServerWebSocket.fromUpgradeRequest(req);

      await socket.start();

      handleSocketStart(req, socket);

      await socket.done;

      handleSocketDone(req, socket);

      return;
    }

    await onRequestPost(req);
  }

  void handleSocketStart(HttpRequest req, ServerWebSocket socket);

  void handleSocketDone(HttpRequest req, ServerWebSocket socket);

  Future close() async {
    await sub.cancel();

    print('$name server closed at $address:$port');
  }
}
