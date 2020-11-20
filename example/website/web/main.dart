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
