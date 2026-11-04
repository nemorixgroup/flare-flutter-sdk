// ---- PChainAddress tests ----

import 'dart:typed_data';

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flare_flutter_sdk/src/wallet/p_chain_address.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sample public key from Flare's official `flare-stake-tool` README.
const _officialPublicKey =
    '02efe41c5d213089cb7a9e808505e9084bb9eb2bf3aa8050ea92a5ae9e20e5a692';

/// P-Chain address the official tool prints for [_officialPublicKey].
const _officialAddress = 'P-flare1pynhfl09rfrf20s83lf6ra5egqylmx757ahxn6';

/// Compressed public key of Hardhat account 0 (address 0xf39F...2266).
const _hardhatPublicKey =
    '038318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed75';

/// Decodes a hex string (no 0x prefix) into bytes.
Uint8List _hex(String hex) => Uint8List.fromList([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);

void main() {
  group('PChainAddress.fromCompressedPublicKey', () {
    // ---- Official vector ----

    test('reproduces the address printed by the official stake tool', () {
      final address = PChainAddress.fromCompressedPublicKey(
        _hex(_officialPublicKey),
        network: FlareNetwork.flare,
      );

      expect(address, _officialAddress);
    });

    // ---- Per-network vectors (Hardhat account 0) ----

    test('derives the expected address on every network', () {
      // Expected values were generated outside Dart with an independent
      // implementation of SHA-256, RIPEMD-160 and Bech32.
      final expected = <FlareNetwork, String>{
        FlareNetwork.flare: 'P-flare15428vq2uzwhm3taey9sr9x5vm6tk78ewmae7dk',
        FlareNetwork.songbird:
            'P-songbird15428vq2uzwhm3taey9sr9x5vm6tk78eww63d63',
        FlareNetwork.coston2: 'P-costwo15428vq2uzwhm3taey9sr9x5vm6tk78ewrnq4xh',
        FlareNetwork.coston: 'P-coston15428vq2uzwhm3taey9sr9x5vm6tk78ew46xnz9',
      };

      for (final entry in expected.entries) {
        expect(
          PChainAddress.fromCompressedPublicKey(
            _hex(_hardhatPublicKey),
            network: entry.key,
          ),
          entry.value,
          reason: entry.key.name,
        );
      }
    });

    // ---- Input validation ----

    test('throws ArgumentError for a key that is too short', () {
      expect(
        () => PChainAddress.fromCompressedPublicKey(
          _hex(_officialPublicKey).sublist(0, 32),
          network: FlareNetwork.flare,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for an uncompressed 65-byte key', () {
      expect(
        () => PChainAddress.fromCompressedPublicKey(
          Uint8List(65)..[0] = 4,
          network: FlareNetwork.flare,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for a 33-byte key with a bad prefix', () {
      expect(
        () => PChainAddress.fromCompressedPublicKey(
          Uint8List(33)..[0] = 4,
          network: FlareNetwork.flare,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PChainAddress.hrpFor', () {
    test('returns the Bech32 prefix of each network', () {
      expect(PChainAddress.hrpFor(FlareNetwork.flare), 'flare');
      expect(PChainAddress.hrpFor(FlareNetwork.songbird), 'songbird');
      expect(PChainAddress.hrpFor(FlareNetwork.coston2), 'costwo');
      expect(PChainAddress.hrpFor(FlareNetwork.coston), 'coston');
    });
  });
}
