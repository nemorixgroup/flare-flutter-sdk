import 'dart:typed_data';

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

// Fixtures shared by the transaction signing tests.
//
// Every expected value (signing payload, signed raw transaction, r, s and
// y parity) was produced outside Dart, with the Python packages
// `eth-account`, `rlp` and `eth_keys`, from the private key of the public
// Hardhat development mnemonic (account 0). The three agree byte for byte,
// and the public key recovered from each signature is the key of
// 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266.

/// The public Hardhat development mnemonic. Never fund its addresses.
const String testMnemonic =
    'test test test test test test test test test test test junk';

/// Decodes a hex string, with or without a `0x` prefix, to bytes.
Uint8List hexToBytes(String hex) {
  final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
  return Uint8List.fromList([
    for (var i = 0; i < clean.length; i += 2)
      int.parse(clean.substring(i, i + 2), radix: 16),
  ]);
}

/// Encodes [bytes] as a lowercase `0x`-prefixed hex string.
String bytesToHex(Uint8List bytes) {
  final buffer = StringBuffer('0x');
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

/// One transaction with its independently generated signed form.
class TxVector {
  /// Creates a [TxVector].
  const TxVector({
    required this.name,
    required this.network,
    required this.chainId,
    required this.nonce,
    required this.maxPriorityFeePerGas,
    required this.maxFeePerGas,
    required this.gasLimit,
    required this.to,
    required this.value,
    required this.dataHex,
    required this.payloadHex,
    required this.rawHex,
    required this.rHex,
    required this.sHex,
    required this.yParity,
  });

  /// Short description, used in test names.
  final String name;

  /// Network whose chain ID signs the transaction.
  final FlareNetwork network;

  /// Chain ID of [network].
  final int chainId;

  /// Transaction nonce.
  final int nonce;

  /// Decimal wei.
  final String maxPriorityFeePerGas;

  /// Decimal wei.
  final String maxFeePerGas;

  /// Gas limit.
  final int gasLimit;

  /// Recipient address.
  final String to;

  /// Decimal wei.
  final String value;

  /// Call data as hex, without prefix.
  final String dataHex;

  /// Expected `0x02 || rlp([...])` signing payload.
  final String payloadHex;

  /// Expected signed raw transaction.
  final String rawHex;

  /// Expected `r`, hex without prefix.
  final String rHex;

  /// Expected `s`, hex without prefix.
  final String sHex;

  /// Expected y parity.
  final int yParity;

  /// The unsigned transaction described by this vector.
  Eip1559Transaction get transaction => Eip1559Transaction(
        nonce: nonce,
        maxPriorityFeePerGas: BigInt.parse(maxPriorityFeePerGas),
        maxFeePerGas: BigInt.parse(maxFeePerGas),
        gasLimit: gasLimit,
        to: to,
        value: BigInt.parse(value),
        data: hexToBytes(dataHex),
      );

  /// Expected `r` as an integer.
  BigInt get r => BigInt.parse(rHex, radix: 16);

  /// Expected `s` as an integer.
  BigInt get s => BigInt.parse(sHex, radix: 16);
}

/// The four vectors, one per network.
const List<TxVector> txVectors = [
  TxVector(
    name: 'transfer on Coston2',
    network: FlareNetwork.coston2,
    chainId: 114,
    nonce: 5,
    maxPriorityFeePerGas: '2000000000',
    maxFeePerGas: '1000000000000',
    gasLimit: 21000,
    to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    value: '1000000000000000000',
    dataHex: '',
    payloadHex:
        '0x02f07205847735940085e8d4a510008252089470997970c51812dc3a010c7d'
        '01b50e0d17dc79c8880de0b6b3a764000080c0',
    rawHex: '0x02f8737205847735940085e8d4a510008252089470997970c51812dc3a010c'
        '7d01b50e0d17dc79c8880de0b6b3a764000080c001a0a75d09e40b503f0cc03b'
        'a9d29ac9890efe22506914ae22352981fa05a35cc6b5a07a01e16129d1472036'
        '5577d223232b335ecedb51f0ef119886630c3179eee48f',
    rHex: 'a75d09e40b503f0cc03ba9d29ac9890efe22506914ae22352981fa05a35cc6b5',
    sHex: '7a01e16129d14720365577d223232b335ecedb51f0ef119886630c3179eee48f',
    yParity: 1,
  ),
  TxVector(
    name: 'ERC-20 transfer on Flare',
    network: FlareNetwork.flare,
    chainId: 14,
    nonce: 0,
    maxPriorityFeePerGas: '0',
    maxFeePerGas: '600000000000',
    gasLimit: 100000,
    to: '0x0000000000000000000000000000000000000001',
    value: '0',
    dataHex: 'a9059cbb00000000000000000000000070997970c51812dc3a010c7d01b50e0d'
        '17dc79c80000000000000000000000000000000000000000000000000de0b6b3'
        'a7640000',
    payloadHex:
        '0x02f86a0e8080858bb2c97000830186a0940000000000000000000000000000'
        '00000000000180b844a9059cbb00000000000000000000000070997970c51812'
        'dc3a010c7d01b50e0d17dc79c800000000000000000000000000000000000000'
        '00000000000de0b6b3a7640000c0',
    rawHex: '0x02f8ad0e8080858bb2c97000830186a0940000000000000000000000000000'
        '00000000000180b844a9059cbb00000000000000000000000070997970c51812'
        'dc3a010c7d01b50e0d17dc79c800000000000000000000000000000000000000'
        '00000000000de0b6b3a7640000c001a03d8d8bcb1e8a92d36e22975d0ead560b'
        '7a44ec6cc549e364eea85afaf701558ba0437b0c090cdc4fe7906ec38afebdcf'
        'a44164037efb6a045cf7c2e0aab46ecebc',
    rHex: '3d8d8bcb1e8a92d36e22975d0ead560b7a44ec6cc549e364eea85afaf701558b',
    sHex: '437b0c090cdc4fe7906ec38afebdcfa44164037efb6a045cf7c2e0aab46ecebc',
    yParity: 1,
  ),
  TxVector(
    name: 'large values on Songbird',
    network: FlareNetwork.songbird,
    chainId: 19,
    nonce: 300,
    maxPriorityFeePerGas: '1000000000',
    maxFeePerGas: '18446744073709551621',
    gasLimit: 3000000,
    to: '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
    value: '123456789012345678901',
    dataHex: '',
    payloadHex:
        '0x02f8381382012c843b9aca0089010000000000000005832dc6c0943c44cddd'
        'b6a900fa2b585dd299e03d12fa4293bc8906b14e9f812f366c3580c0',
    rawHex: '0x02f87b1382012c843b9aca0089010000000000000005832dc6c0943c44cddd'
        'b6a900fa2b585dd299e03d12fa4293bc8906b14e9f812f366c3580c080a0fe1c'
        'd4777ebf8a8030696d9d0e8a51aa5092903583e1993b6902286d43fa89e6a063'
        'e880a8070e1a2b43693f4ee6ccb991e9e5063c52be758aa056e2d896333b5b',
    rHex: 'fe1cd4777ebf8a8030696d9d0e8a51aa5092903583e1993b6902286d43fa89e6',
    sHex: '63e880a8070e1a2b43693f4ee6ccb991e9e5063c52be758aa056e2d896333b5b',
    yParity: 0,
  ),
  TxVector(
    name: 'minimal values on Coston',
    network: FlareNetwork.coston,
    chainId: 16,
    nonce: 0,
    maxPriorityFeePerGas: '0',
    maxFeePerGas: '0',
    gasLimit: 21000,
    to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    value: '0',
    dataHex: '',
    payloadHex:
        '0x02df108080808252089470997970c51812dc3a010c7d01b50e0d17dc79c880'
        '80c0',
    rawHex: '0x02f862108080808252089470997970c51812dc3a010c7d01b50e0d17dc79c8'
        '8080c001a06893034675646c73944944620f6172499779552fe2a35db87fe095'
        '59389d0db4a022049047f61b15763b6682ffab5f91617763dfd6f27fa6382832'
        '32482e1df14d',
    rHex: '6893034675646c73944944620f6172499779552fe2a35db87fe09559389d0db4',
    sHex: '22049047f61b15763b6682ffab5f91617763dfd6f27fa638283232482e1df14d',
    yParity: 1,
  ),
];
