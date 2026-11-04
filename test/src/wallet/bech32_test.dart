// ---- Bech32 tests ----

import 'package:flare_flutter_sdk/src/wallet/bech32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bech32.encode', () {
    // ---- BIP-173 valid test vectors ----

    test('encodes an empty payload (BIP-173 vector a12uel5l)', () {
      expect(Bech32.encode('a', []), 'a12uel5l');
    });

    test('encodes all 32 symbols (BIP-173 vector abcdef1qpzry...)', () {
      final data = List<int>.generate(32, (i) => i);

      expect(
        Bech32.encode('abcdef', data),
        'abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw',
      );
    });

    // ---- Input validation ----

    test('throws ArgumentError for an empty human readable part', () {
      expect(() => Bech32.encode('', [0]), throwsA(isA<ArgumentError>()));
    });

    test('throws ArgumentError for an uppercase human readable part', () {
      expect(() => Bech32.encode('Flare', [0]), throwsA(isA<ArgumentError>()));
    });

    test('throws ArgumentError for a value above 31', () {
      expect(() => Bech32.encode('a', [32]), throwsA(isA<ArgumentError>()));
    });

    test('throws ArgumentError for a negative value', () {
      expect(() => Bech32.encode('a', [-1]), throwsA(isA<ArgumentError>()));
    });
  });

  group('Bech32.encodeBytes', () {
    test('encodes an empty byte list like an empty payload', () {
      expect(Bech32.encodeBytes('a', []), 'a12uel5l');
    });

    test('zero pads the last 5-bit group (0xff -> 31, 28)', () {
      // 0xff is 11111111, regrouped as 11111 and 111 followed by 00.
      expect(Bech32.encodeBytes('a', [0xff]), Bech32.encode('a', [31, 28]));
    });
  });
}
