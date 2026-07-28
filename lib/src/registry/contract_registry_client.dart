import 'package:flare_flutter_sdk/src/network/network_config.dart';

// ---- ContractRegistryClient ----

/// Resolves official Flare contract addresses by name via the
/// FlareContractRegistry (same address across all four networks).
class ContractRegistryClient {
  /// Creates a [ContractRegistryClient] for the given [config].
  ContractRegistryClient(this.config);

  /// The network configuration this client resolves contracts against.
  final NetworkConfig config;

  /// Resolves the address of the official contract named [contractName].
  Future<String> getContractAddress(String contractName) async {
    // TODO(nemorix-group): JSON-RPC call to
    // FlareContractRegistry.getContractAddressByName.
    throw UnimplementedError();
  }
}
