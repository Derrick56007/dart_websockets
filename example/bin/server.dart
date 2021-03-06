import 'dart:io';
import 'package:dart_websockets/server.dart';

class MyServer extends FileServer {
  MyServer(String address, int port) : super(address, port);

  @override
  void handleSocketStart(HttpRequest req, ServerWebSocket socket) {
    // when a socket connects to the server we declare the messages to listen to

    socket // listening for the message 'ping'
      ..on('ping', (data) => onPing(socket, data));

    // onPing will be called and passed data whenever the 'ping' message is received
  }

  Future<void> onPing(ServerWebSocket socket, data) async {
    print('received ping: $data');

    // here we send data back to the socket that sent the ping message
    socket.send('pong', {'info': 'hello-world'});
  }
}

// run the server
void main() async {
  const address = '0.0.0.0';
  const defaultPort = 8081;

  final port = Platform.environment.containsKey('PORT') ? int.parse(Platform.environment['PORT']) : defaultPort;

  final server = MyServer(address, port);
  await server.init();
}
