import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pedantic/pedantic.dart';

import '../common/common_websocket.dart';

class ServerWebSocket extends CommonWebSocket {
  HttpRequest _req;
  String _url;

  WebSocket _webSocket;

  ServerWebSocket.fromUpgradeRequest(this._req);

  ServerWebSocket.fromUrl(this._url);

  @override
  void send(String type, [message]) {
    _webSocket
        .add(message == null ? jsonEncode(type) : jsonEncode([type, message]));
  }

  @override
  Future start({int retrySeconds = CommonWebSocket.defaultRetrySeconds}) async {
    if (_url == null) {
      _webSocket = await WebSocketTransformer.upgrade(_req)
        ..listen(onData);

      done = _webSocket.done;
    } else {
      print('connecting to $_url');
      final completer = Completer();

      reconnectScheduled = false;

      unawaited(WebSocket.connect(_url).then((WebSocket s) async {
        print('connected to $_url');
        _webSocket = s;

        completer.complete();

        final doneCompleter = Completer();
        done = doneCompleter.future;

        s.listen(onData, onError: (e) {
          doneCompleter.complete();
        }, onDone: () {
          doneCompleter.complete();
        });

        await done;

        print('disconnected from $_url');

        scheduleReconnect(retrySeconds);
      }, onError: (e) {
        print('could not connect to $_url');

        scheduleReconnect(retrySeconds);
      }));

      return completer.future;
    }
  }
}
