// ---- Secp256k1Signer ----

import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// An ECDSA signature over secp256k1 with its recovery parity.
final class Secp256k1Signature {
  /// Creates a [Secp256k1Signature].
  const Secp256k1Signature({
    required this.r,
    required this.s,
    required this.yParity,
  });

  /// The `r` value, never zero.
  final BigInt r;

  /// The `s` value, in the lower half of the curve order (EIP-2).
  final BigInt s;

  /// Parity of the y coordinate of the nonce point, 0 or 1. It is the
  /// recovery id that lets a verifier compute the signer's public key.
  final int yParity;
}

/// Deterministic secp256k1 signer for Ethereum style transactions.
///
/// Signs a 32-byte hash with the nonce `k` of RFC 6979 (HMAC-SHA256), so
/// the same key and hash always give the same signature. It then applies
/// EIP-2: a signature whose `s` is above half the curve order is replaced
/// by its mirror (`n - s`), and the y parity is flipped with it.
///
/// Internal: not exported from the public barrel. Dart big integers do not
/// run in constant time, so this is meant for client side signing, not for
/// a shared server handling untrusted timing observers.
abstract final class Secp256k1Signer {
  static final ECCurve_secp256k1 _curve = ECCurve_secp256k1();

  /// Half of the curve order, the EIP-2 upper bound for `s`.
  static final BigInt _halfOrder = _curve.n >> 1;

  /// Attempts before giving up on finding a valid nonce. RFC 6979 almost
  /// never needs a second one (the chance is about 2^-128).
  static const int _maxAttempts = 64;

  /// Signs the 32-byte [hash] with the 32-byte [privateKey].
  ///
  /// Throws an [ArgumentError] if [hash] or [privateKey] is not 32 bytes
  /// or the key is not a valid secp256k1 scalar. The key value is never
  /// included in an error message.
  static Secp256k1Signature sign(Uint8List hash, Uint8List privateKey) {
    if (hash.length != 32) {
      throw ArgumentError.value(hash.length, 'hash', 'must be 32 bytes');
    }
    if (privateKey.length != 32) {
      throw ArgumentError('privateKey must be 32 bytes');
    }
    final n = _curve.n;
    final d = _toBigInt(privateKey);
    if (d == BigInt.zero || d >= n) {
      throw ArgumentError('privateKey is not a valid secp256k1 scalar');
    }
    final z = _toBigInt(hash);

    // ---- RFC 6979, section 3.2 (HMAC-SHA256, 256-bit order) ----

    final x = _toBytes(d);
    final h1 = _toBytes(z % n);
    var v = Uint8List.fromList(List<int>.filled(32, 0x01));
    var k = Uint8List(32);
    k = _hmac(k, [...v, 0x00, ...x, ...h1]);
    v = _hmac(k, v);
    k = _hmac(k, [...v, 0x01, ...x, ...h1]);
    v = _hmac(k, v);

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      // One HMAC block is already the 256 bits needed for a candidate.
      v = _hmac(k, v);
      final candidate = _toBigInt(v);
      if (candidate >= BigInt.one && candidate < n) {
        final signature = _trySign(candidate, z, d);
        if (signature != null) {
          return signature;
        }
      }
      k = _hmac(k, [...v, 0x00]);
      v = _hmac(k, v);
    }
    throw StateError('Could not derive a valid signing nonce.');
  }

  // ---- Helpers ----

  /// Signs with the nonce [k], or returns null if it gives an unusable
  /// signature (a case the RFC handles by drawing the next nonce).
  static Secp256k1Signature? _trySign(BigInt k, BigInt z, BigInt d) {
    final n = _curve.n;
    final point = _curve.G * k;
    if (point == null) {
      return null;
    }
    // Uncompressed encoding: 0x04 || X || Y.
    final encoded = point.getEncoded(false);
    final r = _toBigInt(Uint8List.sublistView(encoded, 1, 33));
    // An X at or above the order would need a larger recovery id.
    if (r == BigInt.zero || r >= n) {
      return null;
    }
    var s = (k.modInverse(n) * (z + r * d)) % n;
    if (s == BigInt.zero) {
      return null;
    }
    var yParity = encoded.last & 1;
    if (s > _halfOrder) {
      // Mirroring s mirrors the point, which flips the y parity.
      s = n - s;
      yParity ^= 1;
    }
    return Secp256k1Signature(r: r, s: s, yParity: yParity);
  }

  static Uint8List _hmac(Uint8List key, List<int> data) {
    final mac = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
    return mac.process(Uint8List.fromList(data));
  }

  /// Interprets [bytes] as an unsigned big-endian integer.
  static BigInt _toBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  /// Encodes [value] as exactly 32 big-endian bytes.
  static Uint8List _toBytes(BigInt value) {
    final bytes = Uint8List(32);
    var rest = value;
    for (var i = 31; i >= 0; i--) {
      bytes[i] = (rest & BigInt.from(0xff)).toInt();
      rest >>= 8;
    }
    return bytes;
  }
}
