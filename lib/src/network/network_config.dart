import 'package:flare_flutter_sdk/src/network/flare_network.dart';

// ---- NetworkConfig ----

/// RPC and chain configuration for a given [FlareNetwork].
class NetworkConfig {
  /// Creates a [NetworkConfig] for the given [network], [rpcUrl], and
  /// [chainId].
  const NetworkConfig({
    required this.network,
    required this.rpcUrl,
    required this.chainId,
  });

  /// Resolves the official [NetworkConfig] for the given [network].
  // ignore: avoid_unused_constructor_parameters
  factory NetworkConfig.forNetwork(FlareNetwork network) {
    // TODO(nemorix-group): return official public RPC + chainId per network.
    throw UnimplementedError();
  }

  /// Which Flare network this configuration targets.
  final FlareNetwork network;

  /// The JSON-RPC endpoint URL for this network.
  final String rpcUrl;

  /// The EVM chain ID for this network.
  final int chainId;
}
