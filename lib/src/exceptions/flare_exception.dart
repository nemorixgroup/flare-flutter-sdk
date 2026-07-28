// ---- FlareException ----

/// Base exception for all flare_flutter_sdk errors.
class FlareException implements Exception {
  /// Creates a [FlareException] with the given [message].
  FlareException(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => 'FlareException: $message';
}
