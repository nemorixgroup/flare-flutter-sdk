import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tx_vectors.dart';

void main() {
  // The expected raw transactions are in tx_vectors.dart and were
  // generated outside Dart from the private key of this mnemonic, account 0.
  group('LocalWallet.signTransaction', () {
    for (final vector in txVectors) {
      test(
        'signs to the independent raw transaction (${vector.name})',
        () async {
          final wallet = await LocalWallet.fromMnemonic(
            testMnemonic,
            network: vector.network,
          );

          final raw = await wallet.signTransaction(vector.transaction);

          expect(raw, vector.rawHex);
        },
      );
    }

    test('is bound to the chain ID that signs the transaction', () async {
      for (final vector in txVectors) {
        final wallet = await LocalWallet.fromMnemonic(
          testMnemonic,
          network: vector.network,
        );

        expect(wallet.config.chainId, vector.chainId);
      }
    });

    test('is deterministic', () async {
      final vector = txVectors.first;
      final wallet = await LocalWallet.fromMnemonic(
        testMnemonic,
        network: vector.network,
      );

      final first = await wallet.signTransaction(vector.transaction);
      final second = await wallet.signTransaction(vector.transaction);

      expect(second, first);
    });

    test('gives a different result on another network', () async {
      final vector = txVectors.first;
      final onCoston2 = await LocalWallet.fromMnemonic(
        testMnemonic,
        network: FlareNetwork.coston2,
      );
      final onFlare = await LocalWallet.fromMnemonic(
        testMnemonic,
        network: FlareNetwork.flare,
      );

      final first = await onCoston2.signTransaction(vector.transaction);
      final second = await onFlare.signTransaction(vector.transaction);

      expect(second, isNot(first));
    });

    test('returns a 0x02 prefixed hex string', () async {
      final vector = txVectors.first;
      final wallet = await LocalWallet.fromMnemonic(
        testMnemonic,
        network: vector.network,
      );

      final raw = await wallet.signTransaction(vector.transaction);

      expect(raw, startsWith('0x02'));
      expect(raw, matches(RegExp(r'^0x[0-9a-f]+$')));
    });

    test('rejects anything that is not an Eip1559Transaction', () async {
      final wallet = await LocalWallet.fromMnemonic(
        testMnemonic,
        network: FlareNetwork.coston2,
      );

      expect(wallet.signTransaction('not a transaction'), throwsArgumentError);
      expect(wallet.signTransaction(42), throwsArgumentError);
    });
  });
}
