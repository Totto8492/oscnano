import 'dart:typed_data';

String _parseAddress(Uint8List data) {
  return String.fromCharCodes(data.takeWhile((value) => value != 0));
}

String _parseTypes(Uint8List data) {
  return String.fromCharCodes(
      data.skip(data.indexOf(44) + 1).takeWhile((value) => value != 0));
}

Uint8List _parseArgs(Uint8List data) {
  final pos = data.indexOf(44);
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
    if (t == 'i'.codeUnitAt(0)) {
      final head =
          Uint8List.fromList(seeking.take(4).toList().reversed.toList());
      ret.add(head.buffer.asInt32List()[0]);
      seeking = seeking.skip(4);
    } else if (t == 'f'.codeUnitAt(0)) {
      final head =
          Uint8List.fromList(seeking.take(4).toList().reversed.toList());
      ret.add(head.buffer.asFloat32List()[0]);
      seeking = seeking.skip(4);
    } else if (t == 'F'.codeUnitAt(0)) {
      ret.add(false);
    } else if (t == 'T'.codeUnitAt(0)) {
      ret.add(true);
    } else {
      print('unknown type: $t');
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
