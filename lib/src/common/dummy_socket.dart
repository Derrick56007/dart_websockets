import 'common_websocket.dart';

class DummySocket extends CommonWebSocket {
  @override
  void send(String type, [msg]) =>
      onDecodedData(msg == null ? type : [type, msg]);

  @override
  Future start(
      {int retrySeconds = CommonWebSocket.defaultRetrySeconds}) async {}
}
