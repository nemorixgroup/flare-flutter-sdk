// This is an example file; print statements here are intentional output,
// not debugging leftovers.
// ignore_for_file: avoid_print
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

/// Standalone usage example for [LocalWallet].
///
/// Run directly with:
/// ```sh
/// dart run example/m1/local_wallet_example.dart
/// ```
Future<void> main() async {
  await runLocalWalletExample();
}

/// Derives a wallet from a test mnemonic, prints its C-Chain address, its
/// P-Chain address and its Coston2 balance, and signs a transfer.
///
/// WARNING: the mnemonic below is a public test phrase (the default
/// Hardhat development mnemonic). Never put a real mnemonic in source
/// code, and never fund the addresses derived from this one.
///
/// Extracted as its own function so `flare_flutter_sdk_example.dart` can
/// call it as part of the combined walkthrough.
Future<void> runLocalWalletExample() async {
  const mnemonic =
      'test test test test test test test test test test test junk';

  // The C-Chain address is the same on every Flare network; the network
  // decides the P-Chain prefix, where the balance is read from and the
  // chain ID the wallet signs with.
  final wallet = await LocalWallet.fromMnemonic(
    mnemonic,
    network: FlareNetwork.coston2,
  );

  final address = await wallet.getAddress();
  final pChainAddress = await wallet.getPChainAddress();
  final balanceWei = await wallet.getBalance();

  print('C-Chain address: $address');
  print('P-Chain address: $pChainAddress');
  print('Balance on Coston2: $balanceWei wei');

  // A transfer of 1 FLR. The nonce is fixed here to keep the example
  // offline; a real transaction takes it from the network, and the fees
  // from the network's current base fee.
  final transaction = Eip1559Transaction(
    nonce: 5,
    maxPriorityFeePerGas: BigInt.from(2000000000), // 2 gwei
    maxFeePerGas: BigInt.from(1000000000000), // 1000 gwei
    gasLimit: 21000,
    to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    value: BigInt.from(10).pow(18), // 1 FLR in wei
  );

  // Signing happens on the device and nothing is sent to the network.
  final rawTransaction = await wallet.signTransaction(transaction);
  print('Signed transaction (not sent): $rawTransaction');
}
