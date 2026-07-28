// This is an example file; print statements here are intentional output,
// not debugging leftovers.
// ignore_for_file: avoid_print
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

/// Illustrative usage of flare_flutter_sdk.
///
/// This example reflects the planned v1.0.0 API. It will start running
/// end-to-end once the corresponding milestones land: wallet connection
/// after M1, and the FTSO feed read after M3. Until then, calls below throw
/// [UnimplementedError] by design, the skeleton is intentional scaffolding.
Future<void> main() async {
  // ---- Connect a wallet (available after M1) ----
  final wallet = await LocalWallet.fromMnemonic(
    'test test test test test test test test test test test junk',
  );

  // ---- Read a live FTSO price feed (available after M3) ----
  final registry = ContractRegistryClient(
    NetworkConfig.forNetwork(FlareNetwork.coston2),
  );
  final ftso = FtsoClient(registry);
  final feed = await ftso.getFeedById(
    FeedId.fromName(category: FeedCategory.crypto, name: 'FLR/USD'),
  );

  print('Wallet address: ${await wallet.getAddress()}');
  print('FLR/USD: ${feed.value}');
}
