// ---- Eip1559Transaction ----

import 'dart:typed_data';

import 'package:flare_flutter_sdk/src/transactions/rlp.dart';

/// An unsigned EIP-1559 (type 2) transaction for Flare's C-Chain.
///
/// Flare supports legacy (type 0) and type 2 transactions, serialized
/// following EIP-2718 with RLP. This SDK builds type 2, whose fee is
/// `(baseFee + priorityFee) * gas` and is fully burned.
///
/// The chain ID is deliberately not part of the transaction: the wallet
/// that signs it supplies the chain ID of the network it is bound to, so a
/// transaction cannot be signed for the wrong network by mistake.
///
/// The access list is always empty in this version.
///
/// Example:
///
/// ```dart
/// final tx = Eip1559Transaction(
///   nonce: 0,
///   maxPriorityFeePerGas: BigInt.from(2000000000),
///   maxFeePerGas: BigInt.from(1000000000000),
///   gasLimit: 21000,
///   to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
///   value: BigInt.from(10).pow(18), // 1 FLR
/// );
/// final rawTx = await wallet.signTransaction(tx);
/// ```
///
/// Official reference: https://dev.flare.network/network/overview
class Eip1559Transaction {
  /// Creates an [Eip1559Transaction].
  ///
  /// Throws an [ArgumentError] if a number is negative or does not fit in
  /// 256 bits, if [maxFeePerGas] is below [maxPriorityFeePerGas], or if [to]
  /// is not a `0x`-prefixed 20-byte hex address. The checksum casing of
  /// [to] is not verified.
  Eip1559Transaction({
    required this.nonce,
    required this.maxPriorityFeePerGas,
    required this.maxFeePerGas,
    required this.gasLimit,
    required this.to,
    required this.value,
    Uint8List? data,
  }) : data = Uint8List.fromList(data ?? const <int>[]) {
    _validate();
  }

  /// Number of transactions already sent from the signing account.
  final int nonce;

  /// Maximum tip per unit of gas, in wei.
  final BigInt maxPriorityFeePerGas;

  /// Maximum total fee per unit of gas (base fee plus tip), in wei.
  final BigInt maxFeePerGas;

  /// Maximum gas the transaction may consume.
  final int gasLimit;

  /// Recipient address, `0x` followed by 40 hex characters.
  final String to;

  /// Native amount to transfer, in wei.
  final BigInt value;

  /// Call data, empty for a plain transfer.
  final Uint8List data;

  /// The EIP-2718 transaction type byte of EIP-1559 transactions.
  static const int _typeByte = 0x02;

  static final BigInt _maxUint256 = (BigInt.one << 256) - BigInt.one;

  static final RegExp _addressPattern = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// Returns the payload to hash and sign for [chainId]:
  /// `0x02 || rlp([chainId, nonce, maxPriorityFeePerGas, maxFeePerGas,
  /// gasLimit, to, value, data, accessList])`.
  ///
  /// The signature is made over its Keccak-256 hash.
  ///
  /// Throws an [ArgumentError] if [chainId] is not positive.
  Uint8List encodeForSigning(int chainId) => _encode(chainId, const <Object>[]);

  /// Returns the signed transaction for [chainId]: the signing payload
  /// with `yParity`, `r` and `s` appended to the RLP list.
  ///
  /// Throws an [ArgumentError] if [chainId] is not positive, [yParity] is
  /// not 0 or 1, or [r] or [s] is not positive.
  Uint8List encodeSigned({
    required int chainId,
    required int yParity,
    required BigInt r,
    required BigInt s,
  }) {
    if (yParity != 0 && yParity != 1) {
      throw ArgumentError.value(yParity, 'yParity', 'must be 0 or 1');
    }
    if (r <= BigInt.zero || s <= BigInt.zero) {
      throw ArgumentError('r and s must be positive');
    }
    return _encode(chainId, <Object>[yParity, r, s]);
  }

  // ---- Helpers ----

  Uint8List _encode(int chainId, List<Object> signature) {
    if (chainId <= 0) {
      throw ArgumentError.value(chainId, 'chainId', 'must be positive');
    }
    final payload = Rlp.encode(<Object>[
      chainId,
      nonce,
      maxPriorityFeePerGas,
      maxFeePerGas,
      gasLimit,
      _addressBytes(),
      value,
      data,
      // Access list, always empty in this version.
      <Object>[],
      ...signature,
    ]);
    return Uint8List.fromList([_typeByte, ...payload]);
  }

  /// The 20 raw bytes of [to].
  Uint8List _addressBytes() {
    final bytes = Uint8List(20);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(to.substring(2 + i * 2, 4 + i * 2), radix: 16);
    }
    return bytes;
  }

  void _validate() {
    if (nonce < 0) {
      throw ArgumentError.value(nonce, 'nonce', 'must not be negative');
    }
    if (gasLimit < 0) {
      throw ArgumentError.value(gasLimit, 'gasLimit', 'must not be negative');
    }
    _checkUint256(maxPriorityFeePerGas, 'maxPriorityFeePerGas');
    _checkUint256(maxFeePerGas, 'maxFeePerGas');
    _checkUint256(value, 'value');
    if (maxFeePerGas < maxPriorityFeePerGas) {
      throw ArgumentError.value(
        maxFeePerGas,
        'maxFeePerGas',
        'must not be below maxPriorityFeePerGas',
      );
    }
    if (!_addressPattern.hasMatch(to)) {
      throw ArgumentError.value(
        to,
        'to',
        'must be a 0x-prefixed 20-byte hex address',
      );
    }
  }

  static void _checkUint256(BigInt number, String name) {
    if (number.isNegative || number > _maxUint256) {
      throw ArgumentError.value(number, name, 'must fit in 256 bits');
    }
  }
}
