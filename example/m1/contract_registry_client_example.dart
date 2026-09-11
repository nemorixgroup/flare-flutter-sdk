// This is an example file; print statements here are intentional output,
// not debugging leftovers.
// ignore_for_file: avoid_print
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

/// Standalone usage example for [ContractRegistryClient].
///
/// Run directly with:
/// ```sh
/// dart run example/m1/contract_registry_client_example.dart
/// ```
Future<void> main() async {
  await runContractRegistryClientExample();
}

/// Resolves and prints the WNat contract address on Coston2.
///
/// Extracted as its own function so `flare_flutter_sdk_example.dart` can
/// call it as part of the combined walkthrough.
Future<void> runContractRegistryClientExample() async {
  final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
  final registry = ContractRegistryClient(config);
  final wNatAddress = await registry.getContractAddress('WNat');
  print('WNat address on Coston2: $wNatAddress');
}
