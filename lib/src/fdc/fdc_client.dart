/// Attestation types supported for the FXRP flow in v1.0.0.
enum FdcAttestationType {
  /// Verifies that an address is valid on the underlying chain.
  addressValidity,

  /// Verifies a payment transaction on the underlying chain.
  payment,

  /// Verifies an EVM transaction and its receipt.
  evmTransaction,
}

// ---- FdcClient ----

/// Minimum FDC attestation support required for the FXRP flow (v1.0.0).
class FdcClient {
  /// Creates an [FdcClient].
  FdcClient();

  /// Requests an attestation of the given [type] with the given [params].
  Future<Object> requestAttestation(
    FdcAttestationType type,
    Object params,
  ) async {
    // TODO(nemorix-group): verifier request, FdcHub submit, DA Layer proof.
    throw UnimplementedError();
  }
}
