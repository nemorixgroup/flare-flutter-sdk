// ---- Wallet ----

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

/// Abstract wallet interface. No implementation stores raw private keys
/// outside of [LocalWallet]; SDK code never assumes key custody.
abstract class Wallet {
  /// Creates a [Wallet].
  const Wallet();

  /// Returns the wallet's address.
  Future<String> getAddress();

  /// Returns the wallet's native balance.
  Future<BigInt> getBalance();

  /// Signs the given unsigned transaction and returns the signed payload.
  Future<String> signTransaction(Object unsignedTx);
}
