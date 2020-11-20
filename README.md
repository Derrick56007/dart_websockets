## WebSockets for Dart

`dart_websockets` is a pure dart library for establishing simple 
[WebSocket](https://tools.ietf.org/html/rfc6455) servers and clients.

## Server-Side Usage

```dart
import 'dart:io';
import 'package:dart_websockets/server.dart';

class MyServer extends FileServer {
  MyServer(String address, int port) : super(address, port);

  @override
  void handleSocketStart(HttpRequest req, ServerWebSocket socket) {
    // declare the messages to listen to
    // here we are listening for the message 'ping'
  
    socket //
      ..on('ping', (data) => onPing(socket, data));
      
    // onPing will be called and passed data whenever the 'ping' message is received
  }

  Future<void> onPing(ServerWebSocket socket, data) async {
    print('received ping: $data');

    // here we send data back to the socket that sent the ping message
    socket.send('pong', {'info': 'hello-world'});
  }
}

void main() async {
  const address = '0.0.0.0';
  const defaultPort = 8081;

  final port = Platform.environment.containsKey('PORT') ? int.parse(Platform.environment['PORT']) : defaultPort;

  final server = MyServer(address, port);
  await server.init();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
