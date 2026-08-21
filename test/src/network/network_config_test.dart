import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---- NetworkConfig.forNetwork ----

  group('NetworkConfig.forNetwork', () {
    test('resolves Flare mainnet correctly', () {
      final config = NetworkConfig.forNetwork(FlareNetwork.flare);
      expect(config.chainId, 14);
      expect(config.rpcUrl, 'https://flare-api.flare.network/ext/C/rpc');
      expect(config.currencySymbol, 'FLR');
    });

    test('resolves Songbird correctly', () {
      final config = NetworkConfig.forNetwork(FlareNetwork.songbird);
      expect(config.chainId, 19);
      expect(config.rpcUrl, 'https://songbird-api.flare.network/ext/C/rpc');
      expect(config.currencySymbol, 'SGB');
    });

    test('resolves Coston2 correctly', () {
      final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
      expect(config.chainId, 114);
      expect(config.rpcUrl, 'https://coston2-api.flare.network/ext/C/rpc');
      expect(config.currencySymbol, 'C2FLR');
    });

    test('resolves Coston correctly', () {
      final config = NetworkConfig.forNetwork(FlareNetwork.coston);
      expect(config.chainId, 16);
      expect(config.rpcUrl, 'https://coston-api.flare.network/ext/C/rpc');
      expect(config.currencySymbol, 'CFLR');
    });

    test('each network resolves to a unique chain ID', () {
      final chainIds = FlareNetwork.values
          .map((n) => NetworkConfig.forNetwork(n).chainId)
          .toSet();
      expect(chainIds.length, FlareNetwork.values.length);
    });
  });
}
