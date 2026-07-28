import 'package:flare_flutter_sdk/src/wallet/wallet.dart';

/// Builds and sends native / ERC-20 transfers and generic contract calls.
class TransactionBuilder {
  /// Creates a [TransactionBuilder] backed by the given [wallet].
  TransactionBuilder(this.wallet);

  /// The wallet used to sign transactions built by this class.
  final Wallet wallet;

  /// Sends a native FLR transfer of [amount] to [to].
  Future<String> sendNativeTransfer({
    required String to,
    required BigInt amount,
  }) async {
    // TODO(nemorix-group): implement in M2.
    throw UnimplementedError();
  }
}
