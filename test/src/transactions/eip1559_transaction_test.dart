import 'dart:typed_data';

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tx_vectors.dart';

const String _to = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8';

/// A valid transaction whose fields can be overridden one at a time.
Eip1559Transaction _tx({
  int nonce = 0,
  BigInt? tip,
  BigInt? maxFee,
  int gasLimit = 21000,
  String to = _to,
  BigInt? value,
  Uint8List? data,
}) =>
    Eip1559Transaction(
      nonce: nonce,
      maxPriorityFeePerGas: tip ?? BigInt.one,
      maxFeePerGas: maxFee ?? BigInt.from(10),
      gasLimit: gasLimit,
      to: to,
      value: value ?? BigInt.zero,
      data: data,
    );

void main() {
  // The expected payloads and raw transactions are in tx_vectors.dart and
  // were generated outside Dart.
  group('Eip1559Transaction.encodeForSigning', () {
    for (final vector in txVectors) {
      test('matches the independent payload (${vector.name})', () {
        final payload = vector.transaction.encodeForSigning(vector.chainId);

        expect(bytesToHex(payload), vector.payloadHex);
      });
    }

    test('rejects a chain ID that is not positive', () {
      expect(() => _tx().encodeForSigning(0), throwsArgumentError);
      expect(() => _tx().encodeForSigning(-1), throwsArgumentError);
    });
  });

  group('Eip1559Transaction.encodeSigned', () {
    for (final vector in txVectors) {
      test('matches the independent raw transaction (${vector.name})', () {
        final raw = vector.transaction.encodeSigned(
          chainId: vector.chainId,
          yParity: vector.yParity,
          r: vector.r,
          s: vector.s,
        );

        expect(bytesToHex(raw), vector.rawHex);
      });
    }

    test('rejects a y parity other than 0 or 1', () {
      expect(
        () => _tx().encodeSigned(
          chainId: 1,
          yParity: 2,
          r: BigInt.one,
          s: BigInt.one,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an r or s that is not positive', () {
      expect(
        () => _tx().encodeSigned(
          chainId: 1,
          yParity: 0,
          r: BigInt.zero,
          s: BigInt.one,
        ),
        throwsArgumentError,
      );
      expect(
        () => _tx().encodeSigned(
          chainId: 1,
          yParity: 0,
          r: BigInt.one,
          s: BigInt.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Eip1559Transaction constructor', () {
    test('defaults the data to empty', () {
      expect(_tx().data, isEmpty);
    });

    test('keeps its own copy of the data', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final tx = _tx(data: data);
      data[0] = 9;

      expect(tx.data, [1, 2, 3]);
    });

    test('accepts a max fee equal to the priority fee', () {
      expect(
        () => _tx(tip: BigInt.from(5), maxFee: BigInt.from(5)),
        returnsNormally,
      );
    });

    test('accepts the largest 256-bit value and any hex casing', () {
      final maxUint256 = (BigInt.one << 256) - BigInt.one;

      expect(() => _tx(value: maxUint256), returnsNormally);
      expect(() => _tx(to: '0x${'ab' * 20}'), returnsNormally);
      expect(() => _tx(to: '0x${'AB' * 20}'), returnsNormally);
      expect(() => _tx(to: _to.toLowerCase()), returnsNormally);
    });

    test('rejects a negative nonce or gas limit', () {
      expect(() => _tx(nonce: -1), throwsArgumentError);
      expect(() => _tx(gasLimit: -1), throwsArgumentError);
    });

    test('rejects negative or oversized fees and value', () {
      final tooBig = BigInt.one << 256;

      expect(() => _tx(tip: BigInt.from(-1)), throwsArgumentError);
      expect(() => _tx(maxFee: tooBig), throwsArgumentError);
      expect(() => _tx(value: BigInt.from(-1)), throwsArgumentError);
      expect(() => _tx(value: tooBig), throwsArgumentError);
    });

    test('rejects a max fee below the priority fee', () {
      expect(
        () => _tx(tip: BigInt.from(10), maxFee: BigInt.from(9)),
        throwsArgumentError,
      );
    });

    test('rejects a malformed recipient address', () {
      expect(() => _tx(to: ''), throwsArgumentError);
      expect(() => _tx(to: '0x1234'), throwsArgumentError);
      expect(() => _tx(to: _to.substring(2)), throwsArgumentError);
      expect(() => _tx(to: '0x${'a' * 39}'), throwsArgumentError);
      expect(() => _tx(to: '0x${'a' * 41}'), throwsArgumentError);
      expect(() => _tx(to: '0x${'zz' * 20}'), throwsArgumentError);
    });
  });
}
