import 'package:flare_flutter_sdk/src/network/flare_network.dart';

// ---- NetworkConfig ----

/// Holds the RPC endpoint, chain ID, and native currency symbol needed to
/// connect to a specific [FlareNetwork].
///
/// Flare is not a single network, it exposes four EVM compatible networks
/// (Flare, Songbird, Coston2, Coston), each with its own RPC endpoint and
/// chain ID. This class exists so the rest of the SDK never hardcodes a
/// network specific value directly, every client asks a [NetworkConfig]
/// for the value it needs instead.
///
/// Example:
/// ```dart
/// final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
/// print(config.rpcUrl); // https://coston2-api.flare.network/ext/C/rpc
/// print(config.chainId); // 114
/// ```
///
/// Official documentation:
/// https://dev.flare.network/network/overview
class NetworkConfig {
  /// Creates a [NetworkConfig] for the given [network], [rpcUrl],
  /// [chainId], and [currencySymbol].
  ///
  /// Most callers should use [NetworkConfig.forNetwork] instead of this
  /// constructor directly, since it already holds the correct official
  /// values for each network.
  const NetworkConfig({
    required this.network,
    required this.rpcUrl,
    required this.chainId,
    required this.currencySymbol,
  });

  /// Resolves the official [NetworkConfig] for the given [network].
  ///
  /// Values are sourced from Flare's Network Configuration page and are
  /// fixed per network, they do not change at runtime.
  ///
  /// Example:
  /// ```dart
  /// final config = NetworkConfig.forNetwork(FlareNetwork.flare);
  /// ```
  factory NetworkConfig.forNetwork(FlareNetwork network) {
    // Each network has a fixed public RPC endpoint and EVM chain ID,
    // as published on dev.flare.network's Network Configuration page.
    switch (network) {
      case FlareNetwork.flare:
        return const NetworkConfig(
          network: FlareNetwork.flare,
          rpcUrl: 'https://flare-api.flare.network/ext/C/rpc',
          chainId: 14,
          currencySymbol: 'FLR',
        );
      case FlareNetwork.songbird:
        return const NetworkConfig(
          network: FlareNetwork.songbird,
          rpcUrl: 'https://songbird-api.flare.network/ext/C/rpc',
          chainId: 19,
          currencySymbol: 'SGB',
        );
      case FlareNetwork.coston2:
        return const NetworkConfig(
          network: FlareNetwork.coston2,
          rpcUrl: 'https://coston2-api.flare.network/ext/C/rpc',
          chainId: 114,
          currencySymbol: 'C2FLR',
        );
      case FlareNetwork.coston:
        return const NetworkConfig(
          network: FlareNetwork.coston,
          rpcUrl: 'https://coston-api.flare.network/ext/C/rpc',
          chainId: 16,
          currencySymbol: 'CFLR',
        );
    }
  }

  /// Which of the four Flare networks this configuration targets.
  final FlareNetwork network;

  /// The public JSON-RPC endpoint URL for this network.
  final String rpcUrl;

  /// The EVM chain ID for this network, used when signing transactions
  /// and when some wallets need to confirm they are on the right network.
  final int chainId;

  /// The native currency symbol for this network (e.g. `FLR`, `SGB`).
  final String currencySymbol;
}
