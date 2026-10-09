// ---- LocalWallet tests ----

import 'dart:convert';

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flare_flutter_sdk/src/network/json_rpc_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Default Hardhat/Anvil development mnemonic, widely used as a test vector.
const _hardhatMnemonic =
    'test test test test test test test test test test test junk';

/// Standard BIP-39 test mnemonic (all "abandon" words plus "about").
const _abandonMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

/// Network used by every test; the address does not depend on it.
const FlareNetwork _network = FlareNetwork.coston2;

/// Builds a successful JSON-RPC response carrying [result].
http.Response _rpcResult(String result) => http.Response(
      jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': result}),
      200,
    );

/// Creates a wallet whose RPC traffic is answered by [handler].
Future<LocalWallet> _walletWith(
  http.Response Function(http.Request request) handler,
) {
  final rpc = JsonRpcClient(
    NetworkConfig.forNetwork(_network),
    httpClient: MockClient((request) async => handler(request)),
  );
  return LocalWallet.fromMnemonic(
    _hardhatMnemonic,
    network: _network,
    rpcClient: rpc,
  );
}

void main() {
  group('LocalWallet.fromMnemonic', () {
    // ---- Known vectors (path m/44'/60'/0'/0/N) ----

    test('derives the known Hardhat address at index 0', () async {
      final wallet = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );

      expect(
        await wallet.getAddress(),
        '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
      );
    });

    test('derives the known Hardhat address at addressIndex 1', () async {
      final wallet = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
        addressIndex: 1,
      );

      expect(
        await wallet.getAddress(),
        '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
      );
    });

    test('derives the known address for the BIP-39 "abandon" mnemonic',
        () async {
      final wallet = await LocalWallet.fromMnemonic(
        _abandonMnemonic,
        network: _network,
      );

      expect(
        await wallet.getAddress(),
        '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
    });

    // ---- Address format ----

    test('returns a 0x-prefixed 40-hex-character address', () async {
      final wallet = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );

      expect(
        await wallet.getAddress(),
        matches(RegExp(r'^0x[0-9a-fA-F]{40}$')),
      );
    });

    // ---- Derivation parameters ----

    test('is deterministic for the same inputs', () async {
      final first = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );
      final second = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );

      expect(await first.getAddress(), await second.getAddress());
    });

    test('accountIndex produces a different address', () async {
      final account0 = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );
      final account1 = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
        accountIndex: 1,
      );

      expect(
        await account1.getAddress(),
        isNot(await account0.getAddress()),
      );
    });

    test('a BIP-39 passphrase produces a different address', () async {
      final plain = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
      );
      final protected = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: _network,
        passphrase: 'flare',
      );

      expect(
        await protected.getAddress(),
        isNot(await plain.getAddress()),
      );
    });

    test('tolerates extra whitespace around and between words', () async {
      final wallet = await LocalWallet.fromMnemonic(
        '  test  test test test test test test test test test test  junk\n',
        network: _network,
      );

      expect(
        await wallet.getAddress(),
        '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
      );
    });

    test('the address is the same on every network', () async {
      final coston2 = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.coston2,
      );
      final flare = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.flare,
      );

      expect(await flare.getAddress(), await coston2.getAddress());
    });

    // ---- Network binding ----

    test('exposes the configuration of the network it is bound to', () async {
      final wallet = await LocalWallet.fromMnemonic(
        _hardhatMnemonic,
        network: FlareNetwork.coston2,
      );

      expect(wallet.config.network, FlareNetwork.coston2);
      expect(wallet.config.chainId, 114);
    });

    test('rejects an rpcClient that targets a different network', () {
      final rpc = JsonRpcClient(NetworkConfig.forNetwork(FlareNetwork.flare));

      expect(
        () => LocalWallet.fromMnemonic(
          _hardhatMnemonic,
          network: FlareNetwork.coston2,
          rpcClient: rpc,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    // ---- Error handling ----

    test('throws FlareException for an invalid mnemonic', () {
      expect(
        () => LocalWallet.fromMnemonic(
          'this is not a valid mnemonic',
          network: _network,
        ),
        throwsA(isA<FlareException>()),
      );
    });

    test('throws RangeError for a negative accountIndex', () {
      expect(
        () => LocalWallet.fromMnemonic(
          _hardhatMnemonic,
          network: _network,
          accountIndex: -1,
        ),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws RangeError for a negative addressIndex', () {
      expect(
        () => LocalWallet.fromMnemonic(
          _hardhatMnemonic,
          network: _network,
          addressIndex: -1,
        ),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws RangeError for an index in the hardened range', () {
      expect(
        () => LocalWallet.fromMnemonic(
          _hardhatMnemonic,
          network: _network,
          addressIndex: 0x80000000,
        ),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('LocalWallet.getBalance', () {
    // ---- Successful responses ----

    test('returns zero for a 0x0 balance', () async {
      final wallet = await _walletWith((_) => _rpcResult('0x0'));

      expect(await wallet.getBalance(), BigInt.zero);
    });

    test('returns 1 FLR in wei (10^18)', () async {
      final wallet = await _walletWith((_) => _rpcResult('0xde0b6b3a7640000'));

      expect(await wallet.getBalance(), BigInt.from(10).pow(18));
    });

    test('handles balances beyond 64 bits (1000 FLR = 10^21 wei)', () async {
      final wallet = await _walletWith(
        (_) => _rpcResult('0x3635c9adc5dea00000'),
      );

      expect(await wallet.getBalance(), BigInt.from(10).pow(21));
    });

    // ---- Request shape ----

    test('queries eth_getBalance for its own address at latest', () async {
      late Uri sentUrl;
      late Map<String, dynamic> sentBody;
      final wallet = await _walletWith((request) {
        sentUrl = request.url;
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return _rpcResult('0x0');
      });

      await wallet.getBalance();

      expect(sentUrl.toString(), 'https://coston2-api.flare.network/ext/C/rpc');
      expect(sentBody['method'], 'eth_getBalance');
      expect(sentBody['params'], [await wallet.getAddress(), 'latest']);
    });

    // ---- Error handling ----

    test('throws FlareException when the node returns an RPC error', () async {
      final wallet = await _walletWith(
        (_) => http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'error': {'code': -32000, 'message': 'boom'},
          }),
          200,
        ),
      );

      expect(wallet.getBalance(), throwsA(isA<FlareException>()));
    });

    test('throws FlareException on an HTTP error status', () async {
      final wallet = await _walletWith((_) => http.Response('', 500));

      expect(wallet.getBalance(), throwsA(isA<FlareException>()));
    });

    test('throws FlareException when the result is not hex', () async {
      final wallet = await _walletWith((_) => _rpcResult('not-hex'));

      expect(wallet.getBalance(), throwsA(isA<FlareException>()));
    });

    test('throws FlareException when the result has no digits', () async {
      final wallet = await _walletWith((_) => _rpcResult('0x'));

      expect(wallet.getBalance(), throwsA(isA<FlareException>()));
    });
  });
}
