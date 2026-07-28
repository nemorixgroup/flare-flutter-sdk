// ---- FeedCategory ----

/// Categories of FTSO feeds.
enum FeedCategory {
  /// Cryptocurrency price feeds (e.g. FLR/USD).
  crypto,
}

// ---- FeedId ----

/// Encodes a human-readable feed name into the bytes21 feed ID FTSOv2 uses,
/// so callers never hand-encode it themselves.
class FeedId {
  /// Builds a [FeedId] for the given [category] and [name]
  /// (e.g. category: [FeedCategory.crypto], name: `'FLR/USD'`).
  factory FeedId.fromName({
    // Not used yet; encoding logic lands in M3.
    // ignore: avoid_unused_constructor_parameters
    required FeedCategory category,
    // Not used yet; encoding logic lands in M3.
    // ignore: avoid_unused_constructor_parameters
    required String name,
  }) {
    // TODO(nemorix-group): category byte + ascii-padded name -> bytes21 hex.
    throw UnimplementedError();
  }
}
