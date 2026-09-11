import 'dart:convert';

import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flare_flutter_sdk/src/network/json_rpc_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final config = NetworkConfig.forNetwork(FlareNetwork.coston2);

  // ---- ContractRegistryClient.getContractAddress ----

  group('ContractRegistryClient.getContractAddress', () {
    test('decodes a known address from a mocked RPC response', () async {
      // A 32-byte, right-aligned ABI result for a fake WNat address.
      const fakeAddress = '0xC67DCE33D7A8efA5FfEB961899C73fe01bCe9273';
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': '0x000000000000000000000000${fakeAddress.substring(2)}',
          }),
          200,
        );
      });

      final registry = ContractRegistryClient(
        config,
        rpcClient: JsonRpcClient(config, httpClient: mockClient),
      );

      final result = await registry.getContractAddress('WNat');
      expect(result.toLowerCase(), fakeAddress.toLowerCase());
    });

    test('throws FlareException when the contract name is unknown', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': '0x${''.padLeft(64, '0')}',
          }),
          200,
        );
      });

      final registry = ContractRegistryClient(
        config,
        rpcClient: JsonRpcClient(config, httpClient: mockClient),
      );

      expect(
        () => registry.getContractAddress('NotARealContract'),
        throwsA(isA<FlareException>()),
      );
    });

    test('throws FlareException on a non-200 HTTP response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final registry = ContractRegistryClient(
        config,
        rpcClient: JsonRpcClient(config, httpClient: mockClient),
      );

      expect(
        () => registry.getContractAddress('WNat'),
        throwsA(isA<FlareException>()),
      );
    });
  });
}
