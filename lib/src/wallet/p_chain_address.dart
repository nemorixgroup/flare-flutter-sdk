// ---- PChainAddress ----

import 'dart:typed_data';

import 'package:flare_flutter_sdk/src/network/flare_network.dart';
import 'package:flare_flutter_sdk/src/wallet/bech32.dart';
import 'package:pointycastle/export.dart';

/// Derives Flare P-Chain addresses from a secp256k1 public key.
///
/// Flare has three chains. The C-Chain runs the EVM and uses Ethereum
/// style hex addresses, while the P-Chain coordinates validators and is
/// used for staking and delegation, with Bech32 addresses such as
/// `P-flare1pynhfl09rfrf20s83lf6ra5egqylmx757ahxn6`. Both addresses are
/// derived from the same public key, so a wallet that holds one key has
/// an address on each chain.
///
/// The derivation is SHA-256, then RIPEMD-160, then Bech32 with a
/// per-network prefix. Flare's documentation does not spell out these
/// steps; they follow Avalanche, which Flare forks, and were checked by
/// reproducing the official `flare-stake-tool` sample address from its
/// sample public key.
///
/// Example:
///
/// ```dart
/// final address = PChainAddress.fromCompressedPublicKey(
///   compressedKey,
///   network: FlareNetwork.flare,
/// );
/// print(address); // P-flare1...
/// ```
///
/// Official documentation:
/// https://github.com/flare-foundation/flare-stake-tool
abstract final class PChainAddress {
  /// Returns the Bech32 human readable part used on [network].
  ///
  /// Flare, Songbird and Coston come from the constants in Flare's
  /// `go-flare` repository. Coston2 uses `costwo`, which is confirmed by
  /// the network name in `flare-stake-tool` and by a third party
  /// integration, but is not listed in `go-flare`'s constants page.
  static String hrpFor(FlareNetwork network) {
    switch (network) {
      case FlareNetwork.flare:
        return 'flare';
      case FlareNetwork.songbird:
        return 'songbird';
      case FlareNetwork.coston2:
        return 'costwo';
      case FlareNetwork.coston:
        return 'coston';
    }
  }

  /// Derives the P-Chain address of a 33-byte compressed secp256k1
  /// [publicKey] on [network], including the `P-` prefix.
  ///
  /// Throws an [ArgumentError] if [publicKey] is not a 33-byte compressed
  /// key (first byte `0x02` or `0x03`).
  ///
  /// Example:
  ///
  /// ```dart
  /// final address = PChainAddress.fromCompressedPublicKey(
  ///   key,
  ///   network: FlareNetwork.coston2,
  /// );
  /// ```
  static String fromCompressedPublicKey(
    Uint8List publicKey, {
    required FlareNetwork network,
  }) {
    // A compressed secp256k1 key is a parity byte (02 or 03) plus X.
    if (publicKey.length != 33 || (publicKey[0] != 2 && publicKey[0] != 3)) {
      throw ArgumentError.value(
        publicKey.length,
        'publicKey',
        'must be a 33-byte compressed secp256k1 key',
      );
    }

    // ---- Hashing (SHA-256, then RIPEMD-160) ----

    // The 20-byte payload of the address is RIPEMD-160(SHA-256(key)).
    final sha = SHA256Digest().process(publicKey);
    final hash160 = RIPEMD160Digest().process(sha);

    // ---- Encoding ----

    // Bech32 with the network prefix, then the chain marker used by Flare.
    return 'P-${Bech32.encodeBytes(hrpFor(network), hash160)}';
  }
}
