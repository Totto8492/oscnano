import 'dart:io';
import 'dart:typed_data';

import 'oscnano.dart';

void main(List<String> arguments) {
  _simpleTest();
  _udpTest();
}

void _simpleTest() {
  final data = Uint8List.fromList(
      [47, 105, 110, 116, 0, 0, 0, 0, 44, 105, 0, 0, 0, 0, 0, 99]);

  final message = Message.from(data);
  assert(message.address == '/int');
  assert(message.types == 'i');
  assert(message.args.length == 1);
  assert(message.args[0] == 99);
  print(message);
}

Future<void> _udpTest() async {
  final stream = _recvosc();
  await for (var item in stream) {
    final message = Message.from(item);
    print(message);
  }
}

Stream<Uint8List> _recvosc() async* {
  final sock = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 9001);
  await for (final item in sock) {
    if (item != RawSocketEvent.read) {
      continue;
    }
    final datagram = sock.receive();
    if (datagram == null) {
      return;
    }
    final data = datagram.data;
    yield data;
  }
}
