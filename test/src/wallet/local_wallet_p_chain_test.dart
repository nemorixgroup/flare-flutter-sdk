// ---- LocalWallet P-Chain address tests ----

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

/// Default Hardhat/Anvil development mnemonic, widely used as a test vector.
const _hardhatMnemonic =
    'test test test test test test test test test test test junk';

void main() {
  group('LocalWallet.getPChainAddress', () {
    // ---- Known vectors (Hardhat account 0) ----

    test('derives the expected address on every network', () async {
      // Expected values were generated outside Dart with an independent
      // implementation of secp256k1, SHA-256, RIPEMD-160 and Bech32.
      final expected = <FlareNetwork, String>{
        FlareNetwork.flare: 'P-flare15428vq2uzwhm3taey9sr9x5vm6tk78ewmae7dk',
        FlareNetwork.songbird:
            'P-songbird15428vq2uzwhm3taey9sr9x5vm6tk78eww63d63',
        FlareNetwork.coston2: 'P-costwo15428vq2uzwhm3taey9sr9x5vm6tk78ewrnq4xh',
        FlareNetwork.coston: 'P-coston15428vq2uzwhm3taey9sr9x5vm6tk78ew46xnz9',
      };

      for (final entry in expected.entries) {
        final wallet = await LocalWallet.fromMnemonic(
          _hardhatMnemonic,
          network: entry.key,
        );

        expect(
          await wallet.getPChainAddress(),
          entry.value,
          reason: entry.key.name,
        );
      }
    });

    // ---- Relation to the C-Chain address ----

    test('is a Bech32 address with the P- prefix, not the 0x address',
        () async {
      final wallet = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.flare,
      );

      final pChain = await wallet.getPChainAddress();

      expect(pChain, startsWith('P-flare1'));
      expect(pChain, isNot(await wallet.getAddress()));
    });

    // ---- Derivation parameters ----

    test('accountIndex produces a different address', () async {
      final account0 = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.flare,
      );
      final account1 = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.flare,
        accountIndex: 1,
      );

      expect(
        await account1.getPChainAddress(),
        isNot(await account0.getPChainAddress()),
      );
    });

    test('is deterministic for the same inputs', () async {
      final first = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.coston2,
      );
      final second = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.coston2,
      );

      expect(await first.getPChainAddress(), await second.getPChainAddress());
    });
  });
}
