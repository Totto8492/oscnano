import 'dart:typed_data';

import '../bin/oscnano.dart';

void main(List<String> arguments) {
  _simpleTest();
  _simpleTest2();
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

void _simpleTest2() {
  final address = [47, 105, 110, 116, 105, 110, 116, 0, 0, 0, 0, 0];
  final types = [44, 105, 105, 105, 0, 0, 0, 0];
  final args = [0, 0, 0, 8, 0, 0, 0, 4, 0, 0, 0, 92];
  final data = Uint8List.fromList([...address, ...types, ...args]);

  final message = Message.from(data);
  assert(message.address == '/intint');
  assert(message.types == 'iii');
  assert(message.args.length == 3);
  assert(message.args[0] == 8);
  assert(message.args[1] == 4);
  assert(message.args[2] == 92);
  print(message);
}
