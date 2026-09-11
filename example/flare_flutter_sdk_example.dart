// This is an example file; print statements here are intentional output,
// not debugging leftovers.
import 'm1/contract_registry_client_example.dart';
import 'm1/network_configuration_example.dart';

/// Combined walkthrough of flare_flutter_sdk, milestone by milestone.
///
/// Each milestone's examples also run standalone, see the `m1/`, `m2/`,
/// etc. folders as they land. This file is the canonical entry point
/// pub.dev links to from the package's example tab.
///
/// GitHub:
/// https://github.com/nemorixgroup/flare-flutter-sdk/tree/main/example
Future<void> main() async {
  // ---- M1: Foundation & Wallet ----
  await runNetworkConfigurationExample();
  await runContractRegistryClientExample();
}
