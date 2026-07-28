import 'package:flare_flutter_sdk/src/ftso/feed_id.dart';
import 'package:flare_flutter_sdk/src/registry/contract_registry_client.dart';

/// A single FTSO price feed reading.
class FtsoFeed {
  /// Creates an [FtsoFeed] reading.
  const FtsoFeed({
    required this.value,
    required this.decimals,
    required this.timestamp,
  });

  /// The raw feed value, scaled by [decimals].
  final BigInt value;

  /// Number of decimal places [value] is scaled by.
  final int decimals;

  /// When this feed value was last updated.
  final DateTime timestamp;
}

// ---- FtsoClient ----

/// Reads FTSOv2 block-latency price feeds.
class FtsoClient {
  /// Creates an [FtsoClient] backed by the given [registry].
  FtsoClient(this.registry);

  /// Resolves the FtsoV2 contract address via the Contract Registry.
  final ContractRegistryClient registry;

  /// Reads a single feed by its [feedId].
  Future<FtsoFeed> getFeedById(FeedId feedId) async {
    // TODO(nemorix-group): resolve FtsoV2 address, call getFeedById.
    throw UnimplementedError();
  }

  /// Reads multiple feeds by their [feedIds] in a single call.
  Future<List<FtsoFeed>> getFeedsById(List<FeedId> feedIds) async {
    // TODO(nemorix-group): implement in M3.
    throw UnimplementedError();
  }
}
