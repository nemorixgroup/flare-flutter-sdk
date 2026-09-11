// This is an example file; print statements here are intentional output,
// not debugging leftovers.
// ignore_for_file: avoid_print
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

/// Standalone usage example for [NetworkConfig].
///
/// Run directly with:
/// ```sh
/// dart run example/m1/network_configuration_example.dart
/// ```
Future<void> main() async {
  await runNetworkConfigurationExample();
}

/// Resolves and prints the network configuration for Coston2.
///
/// Extracted as its own function so `flare_flutter_sdk_example.dart` can
/// call it as part of the combined walkthrough.
Future<void> runNetworkConfigurationExample() async {
  final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
  print('Connected to chain ID ${config.chainId} via ${config.rpcUrl}');
}
