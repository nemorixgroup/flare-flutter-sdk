// ---- LocalWallet ----

import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flare_flutter_sdk/src/exceptions/flare_exception.dart';
import 'package:flare_flutter_sdk/src/network/flare_network.dart';
import 'package:flare_flutter_sdk/src/network/json_rpc_client.dart';
import 'package:flare_flutter_sdk/src/network/network_config.dart';
import 'package:flare_flutter_sdk/src/wallet/wallet.dart';
import 'package:pointycastle/export.dart';

/// Local key wallet for desktop/CLI use cases.
///
/// Flare's C-Chain uses the Ethereum address space (20-byte addresses
/// derived from secp256k1 keys), so a [LocalWallet] derives its keys with
/// the standard BIP-44 path `m/44'/60'/account'/0/address`, the same
/// default used by Flare's official `flare-stake-tool`.
///
/// A wallet is bound to one [FlareNetwork] when it is created. The address
/// is identical on every network, but the balance (and, later, the chain
/// ID used for signing) is not, so the network is explicit and required.
///
/// The private key never leaves this class: there is no getter for it.
///
/// Example:
///
/// ```dart
/// final wallet = await LocalWallet.fromMnemonic(
///   'test test test test test test test test test test test junk',
///   network: FlareNetwork.coston2,
/// );
/// print(await wallet.getAddress());
/// // 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
/// print(await wallet.getBalance()); // balance in wei
/// ```
///
/// See the official network reference:
/// https://dev.flare.network/network/overview
class LocalWallet implements Wallet {
  LocalWallet._(this._privateKey, this._address, this._rpc);

  /// Private key bytes, kept in memory only and never exposed.
  // ignore: unused_field, used by the signing step in a later version.
  final Uint8List _privateKey;

  /// EIP-55 checksummed C-Chain address (`0x` + 40 hex characters).
  final String _address;

  /// JSON-RPC client bound to this wallet's network.
  final JsonRpcClient _rpc;

  /// BIP-44 coin type used by Flare's C-Chain (same as Ethereum).
  static const int _coinType = 60;

  /// First index that BIP-32 reserves for hardened derivation.
  static const int _hardenedLimit = 0x80000000;

  /// The network configuration this wallet reads balances from.
  NetworkConfig get config => _rpc.config;

  /// Derives a [LocalWallet] from the given BIP-39 [mnemonic], bound to the
  /// given [network].
  ///
  /// The key is derived at `m/44'/60'/[accountIndex]'/0/[addressIndex]`.
  /// An optional BIP-39 [passphrase] can be supplied (empty by default).
  ///
  /// A [rpcClient] can be supplied for testing; production code should
  /// leave it unset. It must target the same [network].
  ///
  /// Throws a [FlareException] if the [mnemonic] is not a valid BIP-39
  /// phrase, and an [ArgumentError] if an index is out of range or the
  /// [rpcClient] targets a different network.
  static Future<LocalWallet> fromMnemonic(
    String mnemonic, {
    required FlareNetwork network,
    int accountIndex = 0,
    int addressIndex = 0,
    String passphrase = '',
    JsonRpcClient? rpcClient,
  }) async {
    // ---- Input validation ----

    // Collapse repeated whitespace so pasted phrases still validate.
    final normalized = mnemonic.trim().split(RegExp(r'\s+')).join(' ');
    if (!bip39.validateMnemonic(normalized)) {
      throw FlareException('Invalid BIP-39 mnemonic.');
    }
    RangeError.checkValueInInterval(
      accountIndex,
      0,
      _hardenedLimit - 1,
      'accountIndex',
    );
    RangeError.checkValueInInterval(
      addressIndex,
      0,
      _hardenedLimit - 1,
      'addressIndex',
    );
    // An injected client for another network would silently read the wrong
    // balances, so it is rejected up front.
    if (rpcClient != null && rpcClient.config.network != network) {
      throw ArgumentError.value(
        rpcClient,
        'rpcClient',
        'targets ${rpcClient.config.network.name}, expected ${network.name}',
      );
    }

    // ---- Key derivation (BIP-39 -> BIP-32) ----

    // Mnemonic to 64-byte seed (PBKDF2), then HD derivation along the path.
    final seed = bip39.mnemonicToSeed(normalized, passphrase: passphrase);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath(
      "m/44'/$_coinType'/$accountIndex'/0/$addressIndex",
    );
    final privateKey = child.privateKey;
    if (privateKey == null) {
      throw FlareException('Key derivation did not produce a private key.');
    }

    // ---- Address derivation (secp256k1 -> Keccak-256) ----

    // Public key = private key * G, encoded uncompressed (0x04 || X || Y).
    final point = ECCurve_secp256k1().G * _bytesToBigInt(privateKey);
    if (point == null) {
      throw FlareException('Public key derivation failed.');
    }
    final publicKey = point.getEncoded(false);

    // Address = last 20 bytes of Keccak-256(X || Y), dropping the 0x04 prefix.
    final hash = _keccak256(publicKey.sublist(1));
    final addressBytes = hash.sublist(hash.length - 20);

    return LocalWallet._(
      privateKey,
      _toChecksumAddress(addressBytes),
      rpcClient ?? JsonRpcClient(NetworkConfig.forNetwork(network)),
    );
  }

  @override
  Future<String> getAddress() async => _address;

  /// Returns this wallet's native balance, in wei (18 decimals), on the
  /// network the wallet is bound to.
  ///
  /// Throws a [FlareException] if the RPC call fails or the node returns a
  /// value that is not a valid hex quantity.
  ///
  /// Example:
  /// ```dart
  /// final wei = await wallet.getBalance();
  /// final whole = wei ~/ BigInt.from(10).pow(18);
  /// ```
  @override
  Future<BigInt> getBalance() async {
    // Ask the node for the latest balance, a 0x-prefixed hex string in wei.
    final result = await _rpc.call('eth_getBalance', [_address, 'latest']);
    return _parseHexQuantity(result);
  }

  @override
  Future<String> signTransaction(Object unsignedTx) async =>
      throw UnimplementedError();

  // ---- Helpers ----

  /// Parses a JSON-RPC hex quantity such as `0x0` or `0xde0b6b3a7640000`.
  static BigInt _parseHexQuantity(String value) {
    // The Ethereum JSON-RPC spec requires a 0x prefix and at least one digit.
    final parsed = value.startsWith('0x')
        ? BigInt.tryParse(value.substring(2), radix: 16)
        : null;
    if (parsed == null || parsed.isNegative) {
      throw FlareException('Unexpected balance format from node: "$value"');
    }
    return parsed;
  }

  /// Computes the Keccak-256 hash of [data].
  static Uint8List _keccak256(Uint8List data) =>
      KeccakDigest(256).process(data);

  /// Encodes [bytes] as a lowercase hex string without a `0x` prefix.
  static String _toHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Interprets [bytes] as an unsigned big-endian integer.
  static BigInt _bytesToBigInt(Uint8List bytes) =>
      BigInt.parse(_toHex(bytes), radix: 16);

  /// Formats [addressBytes] as an EIP-55 checksummed `0x` address.
  static String _toChecksumAddress(Uint8List addressBytes) {
    final lower = _toHex(addressBytes);
    // The checksum hashes the lowercase hex text, not the raw bytes.
    final hash = _toHex(_keccak256(Uint8List.fromList(lower.codeUnits)));
    final buffer = StringBuffer('0x');
    for (var i = 0; i < lower.length; i++) {
      // Uppercase a letter when the matching hash nibble is 8 or higher.
      final upper = int.parse(hash[i], radix: 16) >= 8;
      buffer.write(upper ? lower[i].toUpperCase() : lower[i]);
    }
    return buffer.toString();
  }
}
