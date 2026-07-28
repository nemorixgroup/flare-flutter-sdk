import 'package:flare_flutter_sdk/src/registry/contract_registry_client.dart';

/// FXRP mint / redeem flow (v1.0.0 scope: FXRP only).
class FAssetsClient {
  /// Creates an [FAssetsClient] backed by the given [registry].
  FAssetsClient(this.registry);

  /// Resolves official Flare contract addresses used by this client.
  final ContractRegistryClient registry;

  /// Mints FXRP for the given [amount] of underlying XRP.
  Future<void> mintFxrp({required BigInt amount}) async {
    // TODO(nemorix-group): agent discovery, collateral reservation,
    // FDC-verified execution.
    throw UnimplementedError();
  }

  /// Redeems FXRP back to the given [amount] of underlying XRP.
  Future<void> redeemFxrp({required BigInt amount}) async {
    // TODO(nemorix-group): implement in M4.
    throw UnimplementedError();
  }
}
