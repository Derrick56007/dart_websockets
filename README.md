## WebSockets for Dart

**dart_websockets** is a pure dart library for establishing **simple** 
[WebSocket](https://tools.ietf.org/html/rfc6455) servers and clients.

## Project Structure

See the [example](https://github.com/Derrick56007/dart_websockets/tree/main/example) folder for more details

```
project/
├── bin
│   └── server.dart
├── website/
│   ├── web/
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   ├── main.dart
│   │   └── styles.css
│   ├── .packages
│   ├── analysis_options.yaml
│   ├── pubspec.lock
│   └── pubspec.yaml
├── .packages
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

## Installation

- Add dart_websockets to your pubspec.yaml dependencies
- Enable webdev (`pub global activate webdev`)
- Run (`webdev build`) inside website/

## Server-Side Usage

```dart
// inside server.dart

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

```

## Client-Side Usage

```dart
// inside main.dart

import 'package:dart_websockets/client.dart';

void main() async {
  final address = '127.0.0.1';
  final port = 8081;

  final client = ClientWebSocket(address, port);
  await client.start();

  client //
    ..on('pong', (data) => onPong(client, data));

  client.send('ping', 'ping data');
}

Future<void> onPong(ClientWebSocket socket, data) async {
  print('pong data: $data');
}
```
