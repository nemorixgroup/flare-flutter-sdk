import 'dart:typed_data';

import 'package:flare_flutter_sdk/src/transactions/rlp.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lowercase hex with a `0x` prefix, for readable expectations.
String _hex(Uint8List bytes) {
  final buffer = StringBuffer('0x');
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

/// [length] bytes of 0x61 ('a'), whose hex form is `61` repeated.
Uint8List _a(int length) => Uint8List.fromList(List<int>.filled(length, 0x61));

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

void main() {
  // Expected values come from the examples in ethereum.org's RLP page and
  // from the Python `rlp` package, an implementation independent of this
  // one.
  group('Rlp.encode integers', () {
    test('encodes zero as the empty string', () {
      expect(_hex(Rlp.encode(0)), '0x80');
      expect(_hex(Rlp.encode(BigInt.zero)), '0x80');
    });

    test('encodes values below 128 as a single byte', () {
      expect(_hex(Rlp.encode(1)), '0x01');
      expect(_hex(Rlp.encode(127)), '0x7f');
    });

    test('encodes values from 128 with a length prefix', () {
      expect(_hex(Rlp.encode(128)), '0x8180');
      expect(_hex(Rlp.encode(255)), '0x81ff');
      expect(_hex(Rlp.encode(256)), '0x820100');
      expect(_hex(Rlp.encode(1024)), '0x820400');
    });

    test('encodes integers beyond 64 bits', () {
      expect(
        _hex(Rlp.encode(BigInt.one << 64)),
        '0x89010000000000000000',
      );
      expect(
        _hex(Rlp.encode((BigInt.one << 256) - BigInt.one)),
        '0xa0${'ff' * 32}',
      );
    });

    test('encodes an int and the equal BigInt identically', () {
      expect(Rlp.encode(1024), Rlp.encode(BigInt.from(1024)));
    });

    test('rejects negative integers', () {
      expect(() => Rlp.encode(-1), throwsArgumentError);
      expect(() => Rlp.encode(BigInt.from(-1)), throwsArgumentError);
    });
  });

  group('Rlp.encode byte strings', () {
    test('encodes the empty string as 0x80', () {
      expect(_hex(Rlp.encode(Uint8List(0))), '0x80');
    });

    test('encodes a single byte below 0x80 as itself', () {
      expect(_hex(Rlp.encode(_bytes([0x00]))), '0x00');
      expect(_hex(Rlp.encode(_bytes([0x7f]))), '0x7f');
    });

    test('prefixes a single byte of 0x80 or more', () {
      expect(_hex(Rlp.encode(_bytes([0x80]))), '0x8180');
    });

    test('uses the short form up to 55 bytes', () {
      expect(_hex(Rlp.encode(_a(55))), '0xb7${'61' * 55}');
    });

    test('switches to the long form at 56 bytes', () {
      expect(_hex(Rlp.encode(_a(56))), '0xb838${'61' * 56}');
    });

    test('encodes 256 and 1024 byte strings', () {
      expect(_hex(Rlp.encode(_a(256))), '0xb90100${'61' * 256}');
      expect(_hex(Rlp.encode(_a(1024))), '0xb90400${'61' * 1024}');
    });

    test('encodes the ethereum.org Lorem ipsum example', () {
      final text = Uint8List.fromList(
        'Lorem ipsum dolor sit amet, consectetur adipisicing elit'.codeUnits,
      );
      final encoded = Rlp.encode(text);

      expect(encoded.length, 58);
      expect(_hex(encoded).startsWith('0xb8384c6f'), isTrue);
    });

    test('does not alias its input', () {
      final input = _bytes([0x01]);
      final encoded = Rlp.encode(input);
      input[0] = 0x02;

      expect(_hex(encoded), '0x01');
    });
  });

  group('Rlp.encode lists', () {
    test('encodes the empty list as 0xc0', () {
      expect(_hex(Rlp.encode(<Object>[])), '0xc0');
    });

    test('encodes the ethereum.org cat and dog example', () {
      final list = <Object>[
        Uint8List.fromList('cat'.codeUnits),
        Uint8List.fromList('dog'.codeUnits),
      ];

      expect(_hex(Rlp.encode(list)), '0xc88363617483646f67');
    });

    test('encodes nested lists', () {
      final list = <Object>[
        <Object>[],
        <Object>[<Object>[]],
        <Object>[
          <Object>[],
          <Object>[<Object>[]],
        ],
      ];

      expect(_hex(Rlp.encode(list)), '0xc7c0c1c0c3c0c1c0');
    });

    test('encodes mixed items', () {
      final list = <Object>[
        Uint8List(0),
        _bytes([0x00]),
        _bytes([0x7f]),
        _bytes([0x80]),
        <Object>[
          _bytes([0x61]),
        ],
      ];

      expect(_hex(Rlp.encode(list)), '0xc780007f8180c161');
    });

    test('encodes integers inside a list', () {
      expect(_hex(Rlp.encode(<Object>[1, 2])), '0xc20102');
      expect(
        _hex(Rlp.encode(<Object>[BigInt.zero, BigInt.from(1024)])),
        '0xc480820400',
      );
    });

    test('switches to the long form at a 56 byte payload', () {
      expect(_hex(Rlp.encode(<Object>[_a(54)])), '0xf7b6${'61' * 54}');
      expect(_hex(Rlp.encode(<Object>[_a(55)])), '0xf838b7${'61' * 55}');
    });

    test('encodes a payload longer than 255 bytes', () {
      expect(
        _hex(Rlp.encode(<Object>[_a(1000)])),
        '0xf903ebb903e8${'61' * 1000}',
      );
    });

    test('treats a plain List<int> as a list of integers, not bytes', () {
      expect(_hex(Rlp.encode(<int>[0x61])), '0xc161');
      expect(_hex(Rlp.encode(_bytes([0x61]))), '0x61');
    });
  });

  group('Rlp.encode errors', () {
    test('rejects unsupported item types', () {
      expect(() => Rlp.encode('text'), throwsArgumentError);
      expect(() => Rlp.encode(1.5), throwsArgumentError);
      expect(() => Rlp.encode(null), throwsArgumentError);
    });

    test('rejects an unsupported item nested in a list', () {
      expect(() => Rlp.encode(<Object>[1, 'text']), throwsArgumentError);
    });
  });
}
