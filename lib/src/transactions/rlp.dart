import 'dart:typed_data';

/// Minimal Recursive Length Prefix (RLP) encoder, the serialization used
/// by Ethereum and by Flare's C-Chain for transactions (EIP-2718).
///
/// Internal: not exported from the public barrel. Encoder only, because
/// nothing in the SDK needs to decode RLP yet.
///
/// Supported items:
/// - [Uint8List]: a byte string
/// - [int] and [BigInt]: a non-negative integer, encoded as its shortest
///   big-endian byte string (zero is the empty string)
/// - any other list: a list of items, encoded recursively
///
/// A plain `List<int>` is treated as a list of integers, never as bytes.
/// Pass a [Uint8List] to encode bytes.
abstract final class Rlp {
  /// Encodes [item] and returns its RLP bytes.
  ///
  /// Throws [ArgumentError] for a negative integer or an unsupported type.
  static Uint8List encode(Object? item) {
    if (item is Uint8List) {
      return _encodeString(item);
    }
    if (item is int) {
      return _encodeString(_integerToBytes(BigInt.from(item)));
    }
    if (item is BigInt) {
      return _encodeString(_integerToBytes(item));
    }
    if (item is List<Object?>) {
      final payload = BytesBuilder(copy: false);
      for (final element in item) {
        payload.add(encode(element));
      }
      return _withPrefix(0xc0, payload.takeBytes());
    }
    throw ArgumentError.value(
      item,
      'item',
      'Unsupported RLP item type: ${item.runtimeType}',
    );
  }

  static Uint8List _encodeString(Uint8List bytes) {
    // A single byte below 0x80 is its own encoding.
    if (bytes.length == 1 && bytes[0] < 0x80) {
      return Uint8List.fromList(bytes);
    }
    return _withPrefix(0x80, bytes);
  }

  /// Prepends the length prefix. [offset] is 0x80 for strings and 0xc0
  /// for lists: a payload of up to 55 bytes gets `offset + length`, and a
  /// longer one gets `offset + 55 + lengthOfLength` followed by the length.
  static Uint8List _withPrefix(int offset, Uint8List payload) {
    final length = payload.length;
    final builder = BytesBuilder(copy: false);
    if (length < 56) {
      builder.addByte(offset + length);
    } else {
      final lengthBytes = _integerToBytes(BigInt.from(length));
      builder
        ..addByte(offset + 55 + lengthBytes.length)
        ..add(lengthBytes);
    }
    builder.add(payload);
    return builder.takeBytes();
  }

  /// Shortest big-endian representation of [value]; zero is empty.
  static Uint8List _integerToBytes(BigInt value) {
    if (value.isNegative) {
      throw ArgumentError.value(
        value,
        'value',
        'RLP integers must not be negative',
      );
    }
    if (value == BigInt.zero) {
      return Uint8List(0);
    }
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) {
      hex = '0$hex';
    }
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
