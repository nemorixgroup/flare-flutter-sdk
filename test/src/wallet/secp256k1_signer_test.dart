import 'dart:typed_data';

import 'package:flare_flutter_sdk/src/wallet/secp256k1_signer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

import '../../tx_vectors.dart';

/// Private key of account 0 of the public Hardhat development mnemonic.
const String _keyHex =
    'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

/// The secp256k1 group order, which is not a valid private key.
const String _orderHex =
    'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141';

/// Half of the group order, the EIP-2 upper bound for `s`.
const String _halfOrderHex =
    '7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0';

/// A hash, the expected signature and whether the raw `s` had to be
/// mirrored into the lower half.
class _SignerVector {
  const _SignerVector({
    required this.hashHex,
    required this.rHex,
    required this.sHex,
    required this.yParity,
    required this.sWasFlipped,
  });

  final String hashHex;
  final String rHex;
  final String sHex;
  final int yParity;
  final bool sWasFlipped;
}

// Generated outside Dart: the nonce comes from the python-ecdsa RFC 6979
// signer and the final (r, s, yParity) from eth_keys, which applies EIP-2.
// Hashes are SHA-256 of "flare-<i>".
const List<_SignerVector> _vectors = [
  _SignerVector(
    hashHex: '8c68e5b99b408ef45722d61760fa9eeebd30ad12616a2d4360f5a8e0bf3872fe',
    rHex: 'ce09194608b79366d9b48bf0aa99931dc39b88a21fe831e6c430a753e7eda965',
    sHex: '63963bf8f7f9995c7fe4cc623b0b17913a37268c0d4902e943b574dccd91c128',
    yParity: 0,
    sWasFlipped: false,
  ),
  _SignerVector(
    hashHex: '57832abefc28a9e9c7a936c92c4cc1b0efbe02f3c61938aa6274f5fef7da70fb',
    rHex: 'c7ac01ec6dec51c27f4357b8ce842527eb4842ed12b08c812e43798bb7497d1f',
    sHex: '2df35777c67a649d1e37ac2b7da23d907a823e99099e9ac0e0bd15b4ba09a46b',
    yParity: 0,
    sWasFlipped: true,
  ),
  _SignerVector(
    hashHex: '6f2f5c793a40d4c401d4caafa31a651f6e214b24d6827a85a8fb4d9e1bc7b676',
    rHex: '9d63198df0fc4a6847e1bb36a27bb264e726d059940646b29180da09e3218fbe',
    sHex: '1cdc2417772f94eed53c4882698eeacc84d6c124b76bd7c19fac96bde43dfbd9',
    yParity: 1,
    sWasFlipped: false,
  ),
  _SignerVector(
    hashHex: 'cea5a359b81c9d05b545ea227729b07e42e3175080fc0b48cc559a5be301ff4c',
    rHex: 'eaf9c427262675b9169611554960a75b5c51c72db289edfd432afe105587c46e',
    sHex: '54416e3333c594b02684e08377f36421c93059f4848a2ea725c3f2e63335dbd2',
    yParity: 0,
    sWasFlipped: true,
  ),
  _SignerVector(
    hashHex: '11746d5e9b6cc1ec131f6cfe8519351fecd84a010c6534527b7467144880488e',
    rHex: 'd287a8a64ce1af6d5f517981ee44af659821192301bfe2070181ac22290ff70c',
    sHex: '184fa97ffca11ac2c1a9a5ba7b1b0e0048ccb4addcc9c5c054ec796fdd9e7f83',
    yParity: 1,
    sWasFlipped: false,
  ),
  _SignerVector(
    hashHex: '22615eea8b15159b3ec38180e12a047ce98273ecf5b41b03fe351b74075e270d',
    rHex: '2ecc0a3e593d4afbbbdd9a8783dbca4aa05dbb923cfad650f6637667bbbcfe62',
    sHex: '6fc683010574b26d4cc706fb896c16a16651059bcca2813c790a901f0e76e8fd',
    yParity: 1,
    sWasFlipped: true,
  ),
];

void main() {
  final key = hexToBytes(_keyHex);

  group('Secp256k1Signer.sign', () {
    for (final vector in _vectors) {
      test(
        'matches the independent vector for hash '
        '${vector.hashHex.substring(0, 8)} '
        '(s mirrored: ${vector.sWasFlipped})',
        () {
          final signature = Secp256k1Signer.sign(
            hexToBytes(vector.hashHex),
            key,
          );

          expect(signature.r, BigInt.parse(vector.rHex, radix: 16));
          expect(signature.s, BigInt.parse(vector.sHex, radix: 16));
          expect(signature.yParity, vector.yParity);
        },
      );
    }

    test('is deterministic', () {
      final hash = hexToBytes(_vectors.first.hashHex);
      final first = Secp256k1Signer.sign(hash, key);
      final second = Secp256k1Signer.sign(hash, key);

      expect(second.r, first.r);
      expect(second.s, first.s);
      expect(second.yParity, first.yParity);
    });

    test('always gives s in the lower half and a parity of 0 or 1', () {
      final half = BigInt.parse(_halfOrderHex, radix: 16);
      for (var i = 0; i < 30; i++) {
        final hash = SHA256Digest().process(
          Uint8List.fromList('sample-$i'.codeUnits),
        );
        final signature = Secp256k1Signer.sign(hash, key);

        expect(signature.s <= half, isTrue, reason: 'hash $i');
        expect(signature.r > BigInt.zero, isTrue, reason: 'hash $i');
        expect(signature.yParity, anyOf(0, 1), reason: 'hash $i');
      }
    });

    test('rejects a hash that is not 32 bytes', () {
      expect(
        () => Secp256k1Signer.sign(Uint8List(31), key),
        throwsArgumentError,
      );
      expect(
        () => Secp256k1Signer.sign(Uint8List(33), key),
        throwsArgumentError,
      );
    });

    test('rejects a private key that is not 32 bytes', () {
      final hash = hexToBytes(_vectors.first.hashHex);

      expect(
        () => Secp256k1Signer.sign(hash, Uint8List(31)),
        throwsArgumentError,
      );
    });

    test('rejects a zero private key and one equal to the group order', () {
      final hash = hexToBytes(_vectors.first.hashHex);

      expect(
        () => Secp256k1Signer.sign(hash, Uint8List(32)),
        throwsArgumentError,
      );
      expect(
        () => Secp256k1Signer.sign(hash, hexToBytes(_orderHex)),
        throwsArgumentError,
      );
    });

    test('never includes the private key in an error message', () {
      final hash = hexToBytes(_vectors.first.hashHex);

      expect(
        () => Secp256k1Signer.sign(hash, hexToBytes(_orderHex)),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.toString(),
            'message',
            isNot(contains(_orderHex)),
          ),
        ),
      );
    });
  });
}
