import 'dart:typed_data';

int _codeUnit(String string) {
  assert(string.length == 1);
  return string.codeUnits.first;
}

String _parseAddress(Uint8List data) {
  return String.fromCharCodes(data.takeWhile((value) => value != 0));
}

String _parseTypes(Uint8List data) {
  final pos = data.indexOf(_codeUnit(','));
  return String.fromCharCodes(
      data.skip(pos + 1).takeWhile((value) => value != 0));
}

Uint8List _parseArgs(Uint8List data) {
  final pos = data.indexOf(_codeUnit(','));
  for (var i = data.skip(pos);; i = i.skip(4)) {
    if (i.elementAt(3) == 0) {
      return Uint8List.fromList(i.skip(4).toList());
    }
  }
}

List<dynamic> _argsToList(Uint8List data) {
  final types = _parseTypes(data);
  var seeking = _parseArgs(data).skip(0);
  List<dynamic> ret = [];
  for (final t in types.codeUnits) {
    if (t == _codeUnit('i')) {
      final head =
          Uint8List.fromList(seeking.take(4).toList().reversed.toList());
      ret.add(head.buffer.asInt32List()[0]);
      seeking = seeking.skip(4);
    } else if (t == _codeUnit('f')) {
      final head =
          Uint8List.fromList(seeking.take(4).toList().reversed.toList());
      ret.add(head.buffer.asFloat32List()[0]);
      seeking = seeking.skip(4);
    } else if (t == _codeUnit('F')) {
      ret.add(false);
    } else if (t == _codeUnit('T')) {
      ret.add(true);
    } else {
      throw UnimplementedError();
    }
  }
  return ret;
}

class Message {
  String _address;
  String get address => _address;

  String _types;
  String get types => _types;

  List<dynamic> _args;
  List<dynamic> get args => _args;

  Message(this._address, this._types, this._args);

  factory Message.from(Uint8List data) {
    final address = _parseAddress(data);
    final types = _parseTypes(data);
    final args = _argsToList(data);
    return Message(address, types, args);
  }

  @override
  String toString() => '[\'$_address\', $_types, $args]';
}
