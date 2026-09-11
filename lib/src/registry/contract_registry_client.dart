import 'dart:convert';
import 'dart:typed_data';

import 'package:flare_flutter_sdk/src/exceptions/flare_exception.dart';
import 'package:flare_flutter_sdk/src/network/json_rpc_client.dart';
import 'package:flare_flutter_sdk/src/network/network_config.dart';
import 'package:pointycastle/digests/keccak.dart';

// ---- ContractRegistryClient ----

/// Resolves official Flare contract addresses by name via the
/// FlareContractRegistry, the single trusted source for protocol contract
/// addresses on every Flare network.
///
/// The registry is deployed at the same address on all four networks
/// (Flare, Songbird, Coston2, Coston), so callers never need to know a
/// contract's address ahead of time, only its registered name.
///
/// Example:
/// ```dart
/// final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
/// final registry = ContractRegistryClient(config);
/// final ftsoAddress = await registry.getContractAddress('FtsoV2');
/// ```
///
/// Official documentation:
/// https://dev.flare.network/network/guides/flare-contracts-registry
class ContractRegistryClient {
  /// Creates a [ContractRegistryClient] for the given [config].
  ///
  /// A [rpcClient] can be supplied for testing; production code should
  /// leave it unset.
  ContractRegistryClient(this.config, {JsonRpcClient? rpcClient})
      : _rpc = rpcClient ?? JsonRpcClient(config);

  /// The FlareContractRegistry address, fixed and identical on every
  /// Flare network.
  static const String registryAddress =
      '0xaD67FE66660Fb8dFE9d6b1b4240d8650e30F6019';

  /// The network configuration this client resolves contracts against.
  final NetworkConfig config;

  /// The JSON-RPC client used to query the registry.
  final JsonRpcClient _rpc;

  /// Resolves the address of the official contract named [contractName]
  /// (e.g. `'FtsoV2'`, `'WNat'`, `'AssetManager'`).
  ///
  /// Throws [FlareException] if [contractName] is not a registered
  /// contract on this network, or if the RPC call fails.
  ///
  /// Example:
  /// ```dart
  /// final wNatAddress = await registry.getContractAddress('WNat');
  /// ```
  Future<String> getContractAddress(String contractName) async {
    // Build the eth_call payload: function selector + ABI-encoded string.
    final callData = _encodeGetContractAddressByName(contractName);

    final result = await _rpc.call('eth_call', [
      {'to': registryAddress, 'data': callData},
      'latest',
    ]);

    final address = _decodeAddress(result);

    // The registry returns the zero address for an unknown contract name
    // instead of reverting, so this must be checked explicitly.
    if (address == '0x0000000000000000000000000000000000000000') {
      throw FlareException(
        'No contract registered under the name "$contractName" on '
        '${config.network.name}',
      );
    }

    return address;
  }

  // ---- ABI Encoding ----

  /// Encodes a call to `getContractAddressByName(string)`: the 4-byte
  /// function selector followed by the ABI-encoded [contractName].
  String _encodeGetContractAddressByName(String contractName) {
    final selector = _functionSelector('getContractAddressByName(string)');
    final encodedString = _encodeString(contractName);
    return '0x${_bytesToHex(selector)}$encodedString';
  }

  /// Computes the 4-byte function selector for a Solidity [signature],
  /// the first 4 bytes of its Keccak-256 hash.
  Uint8List _functionSelector(String signature) {
    final digest = KeccakDigest(256);
    final hash = digest.process(Uint8List.fromList(utf8.encode(signature)));
    return hash.sublist(0, 4);
  }

  /// ABI-encodes a single dynamic `string` parameter: offset, length,
  /// then the UTF-8 bytes right-padded to a multiple of 32 bytes.
  String _encodeString(String value) {
    final bytes = Uint8List.fromList(utf8.encode(value));
    final offset = '20'.padLeft(64, '0'); // word offset 0x20, single parameter
    final length = bytes.length.toRadixString(16).padLeft(64, '0');
    final paddedLength = ((bytes.length + 31) ~/ 32) * 32;
    final padded = Uint8List(paddedLength)..setRange(0, bytes.length, bytes);
    return '$offset$length${_bytesToHex(padded)}';
  }

  // ---- ABI Decoding ----

  /// Decodes a 32-byte, right-aligned ABI address result into a
  /// `0x`-prefixed Ethereum-style address.
  String _decodeAddress(String hexResult) {
    final hex = hexResult.startsWith('0x') ? hexResult.substring(2) : hexResult;
    // An address occupies the last 20 bytes (40 hex chars) of the 32-byte
    // word the EVM returns.
    final addressHex = hex.substring(hex.length - 40);
    return '0x$addressHex';
  }

  /// Converts raw [bytes] to a lowercase hex string, no `0x` prefix.
  String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
