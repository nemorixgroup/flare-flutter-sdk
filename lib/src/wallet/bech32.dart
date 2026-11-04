// ---- Bech32 ----

/// Minimal Bech32 encoder (BIP-173), used to build P-Chain addresses.
///
/// Flare's P-Chain addresses are Bech32 strings, the same format Avalanche
/// uses, while C-Chain addresses use the Ethereum hex format. The SDK only
/// derives addresses and never parses them, so this class has no decoder
/// and the SDK needs no Bech32 package.
///
/// Example:
///
/// ```dart
/// print(Bech32.encode('a', [])); // a12uel5l
/// ```
///
/// Specification:
/// https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
abstract final class Bech32 {
  /// The 32-character Bech32 alphabet, indexed by 5-bit value.
  static const String _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

  /// Generator coefficients of the BCH checksum code.
  static const List<int> _generator = [
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3,
  ];

  /// Encodes 5-bit [data] values with the human readable part [hrp].
  ///
  /// Throws an [ArgumentError] if [hrp] is empty, not lowercase or not
  /// printable ASCII, or if any value in [data] is outside 0 to 31.
  ///
  /// Example:
  ///
  /// ```dart
  /// final text = Bech32.encode('abcdef', List<int>.generate(32, (i) => i));
  /// // abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw
  /// ```
  static String encode(String hrp, List<int> data) {
    // ---- Input validation ----

    // This encoder only emits lowercase, which BIP-173 allows.
    if (hrp.isEmpty ||
        hrp != hrp.toLowerCase() ||
        hrp.codeUnits.any((c) => c < 33 || c > 126)) {
      throw ArgumentError.value(
        hrp,
        'hrp',
        'must be non-empty, lowercase, printable ASCII',
      );
    }
    for (final value in data) {
      if (value < 0 || value > 31) {
        throw ArgumentError.value(value, 'data', 'must be in the range 0-31');
      }
    }

    // ---- Encoding ----

    // Data part = payload followed by the 6-value checksum, as characters.
    final checksum = _createChecksum(hrp, data);
    final encoded = [...data, ...checksum].map((v) => _charset[v]).join();
    return '${hrp}1$encoded';
  }

  /// Encodes raw [bytes] with the human readable part [hrp].
  ///
  /// The bytes are regrouped into 5-bit values (zero padded) and then
  /// passed to [encode].
  ///
  /// Example:
  ///
  /// ```dart
  /// final text = Bech32.encodeBytes('flare', hash160);
  /// ```
  static String encodeBytes(String hrp, List<int> bytes) =>
      encode(hrp, _bytesToFiveBit(bytes));

  // ---- Helpers ----

  /// Regroups 8-bit [bytes] into 5-bit values, padding the last group
  /// with zero bits.
  static List<int> _bytesToFiveBit(List<int> bytes) {
    var accumulator = 0;
    var bits = 0;
    final result = <int>[];
    for (final byte in bytes) {
      accumulator = (accumulator << 8) | byte;
      bits += 8;
      // Emit every complete 5-bit group, then keep only the leftover bits.
      while (bits >= 5) {
        bits -= 5;
        result.add((accumulator >> bits) & 31);
      }
      accumulator &= (1 << bits) - 1;
    }
    if (bits > 0) {
      result.add((accumulator << (5 - bits)) & 31);
    }
    return result;
  }

  /// Expands [hrp] into the values mixed into the checksum.
  static List<int> _expandHrp(String hrp) => [
        for (final c in hrp.codeUnits) c >> 5,
        0,
        for (final c in hrp.codeUnits) c & 31,
      ];

  /// Computes the BCH checksum polynomial over [values].
  static int _polymod(List<int> values) {
    var checksum = 1;
    for (final value in values) {
      final top = checksum >> 25;
      checksum = ((checksum & 0x1ffffff) << 5) ^ value;
      for (var i = 0; i < 5; i++) {
        if (((top >> i) & 1) == 1) {
          checksum ^= _generator[i];
        }
      }
    }
    return checksum;
  }

  /// Returns the six 5-bit checksum values for [hrp] and [data].
  static List<int> _createChecksum(String hrp, List<int> data) {
    final values = [..._expandHrp(hrp), ...data, 0, 0, 0, 0, 0, 0];
    final polymod = _polymod(values) ^ 1;
    return [for (var i = 0; i < 6; i++) (polymod >> (5 * (5 - i))) & 31];
  }
}
