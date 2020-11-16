import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../common/common_websocket.dart';

class ClientWebSocket extends CommonWebSocket {
  WebSocket _webSocket;

  bool _connected = false;

  bool isConnected() => _connected;

  Stream<Event> onOpen, onClose, onError;

  final String address;
  final int port;

  ClientWebSocket(this.address, this.port);

  @override
  Future start({int retrySeconds = CommonWebSocket.defaultRetrySeconds}) {
    final completer = Completer();

    reconnectScheduled = false;

    _webSocket = WebSocket('ws://$address:$port');

    _webSocket
      ..onOpen.listen((Event e) {
        _connected = true;

        completer.complete();
      })
      ..onMessage.listen((MessageEvent e) {
        onData(e.data);
      })
      ..onClose.listen((Event e) {
        _connected = false;
        scheduleReconnect(retrySeconds);
      })
      ..onError.listen((Event e) {
        _connected = false;
        scheduleReconnect(retrySeconds);
      });

    onOpen = _webSocket.onOpen;
    onClose = _webSocket.onClose;
    onError = _webSocket.onError;

    return completer.future;
  }

  @override
  void send(String type, [message]) =>
      _webSocket.send(message == null ? jsonEncode(type) : jsonEncode([type, message]));
}
