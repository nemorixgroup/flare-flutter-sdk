import 'package:flare_flutter_sdk/src/wallet/wallet.dart';

/// Local key wallet for desktop/CLI use cases.
class LocalWallet implements Wallet {
  LocalWallet._();

  /// Derives a [LocalWallet] from the given BIP-39 [mnemonic].
  static Future<LocalWallet> fromMnemonic(String mnemonic) async {
    // TODO(nemorix-group): bip39 -> bip32 -> secp256k1 derivation.
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
