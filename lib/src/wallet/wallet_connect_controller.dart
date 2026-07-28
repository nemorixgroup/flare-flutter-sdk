import 'package:flare_flutter_sdk/src/wallet/wallet.dart';

/// EIP-1193-style wallet connection via Reown WalletKit.
class WalletConnectController implements Wallet {
  /// Creates a [WalletConnectController].
  WalletConnectController();

  /// Opens a WalletConnect session with the user's wallet app.
  Future<void> connect() async {
    // TODO(nemorix-group): reown_walletkit session setup.
    throw UnimplementedError();
  }

  @override
  Future<String> getAddress() async => throw UnimplementedError();

  @override
  Future<BigInt> getBalance() async => throw UnimplementedError();

  @override
  Future<String> signTransaction(Object unsignedTx) async =>
      throw UnimplementedError();
}
