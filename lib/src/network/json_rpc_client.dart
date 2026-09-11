import 'dart:convert';

import 'package:flare_flutter_sdk/src/exceptions/flare_exception.dart';
import 'package:flare_flutter_sdk/src/network/network_config.dart';
import 'package:http/http.dart' as http;

// ---- JsonRpcClient ----

/// A minimal JSON-RPC 2.0 client for talking to a Flare network's public
/// RPC endpoint over HTTPS.
///
/// This is the shared low level transport every module that reads from or
/// writes to a Flare network uses (Contract Registry, wallets,
/// transactions, FTSO, FAssets, FDC), so it lives in `network/` rather
/// than inside any single feature module.
///
/// Example:
/// ```dart
/// final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
/// final rpc = JsonRpcClient(config);
/// final chainIdHex = await rpc.call('eth_chainId', []);
/// ```
///
/// Official documentation:
/// https://dev.flare.network/network/guides/flare-for-javascript-developers/
class JsonRpcClient {
  /// Creates a [JsonRpcClient] for the network described by [config].
  ///
  /// An [httpClient] can be supplied for testing; production code should
  /// leave it unset, a new [http.Client] is created internally.
  JsonRpcClient(this.config, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// The network this client sends requests to.
  final NetworkConfig config;

  /// The underlying HTTP client used to send requests.
  final http.Client _httpClient;

  /// Sends a JSON-RPC 2.0 request for [method] with the given [params]
  /// and returns the raw `result` field from the response.
  ///
  /// Throws [FlareException] if the transport fails, the response body is
  /// not valid JSON, or the node returns a JSON-RPC error object.
  ///
  /// Example:
  /// ```dart
  /// final balanceHex = await rpc.call('eth_getBalance', [address, 'latest']);
  /// ```
  Future<String> call(String method, List<dynamic> params) async {
    // Build the JSON-RPC 2.0 envelope Flare's nodes expect.
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': 1,
    });

    // Send the request over HTTPS to this network's public RPC endpoint.
    final response = await _httpClient.post(
      Uri.parse(config.rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw FlareException(
        'RPC call to ${config.rpcUrl} failed with HTTP '
        '${response.statusCode}',
      );
    }

    // Parse the response and surface a JSON-RPC error object, if present,
    // as a FlareException instead of returning a null result silently.
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      throw FlareException('RPC error: ${decoded['error']}');
    }

    return decoded['result'] as String;
  }
}
