import 'common_websocket.dart';

class DummySocket extends CommonWebSocket {
  @override
  void send(String type, [msg]) {
    if (msg == null) {
      onDecodedData(type);
    } else {
      onDecodedData([type, msg]);
    }
  }

  @override
  Future start({int retrySeconds = CommonWebSocket.defaultRetrySeconds}) async {
    return;
  }
}
