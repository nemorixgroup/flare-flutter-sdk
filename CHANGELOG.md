# Changelog
 
All notable changes to this project are documented in this file.
 
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/)
(with `-dev` pre-release tags before v1.0.0).

## 0.0.4-dev

M1 in progress: local wallet key derivation and balance reads
implemented and verified against known test vectors.

### Added

- `LocalWallet.fromMnemonic()`: derives a wallet from a BIP-39 mnemonic
  along the BIP-44 path `m/44'/60'/account'/0/address`, with optional
  `accountIndex`, `addressIndex`, and BIP-39 `passphrase`
- `LocalWallet.getAddress()`: returns the C-Chain address with an
  EIP-55 checksum
- `LocalWallet.getBalance()`: reads the native balance in wei via
  `eth_getBalance` on the network the wallet is bound to
- `LocalWallet.config`: exposes the `NetworkConfig` of the wallet's
  network
- `example/m1/local_wallet_example.dart`, also added to the combined
  walkthrough
- 23 unit tests: known vectors (Hardhat accounts 0 and 1, the BIP-39
  "abandon" mnemonic), derivation parameters, network binding, input
  validation, and `getBalance` against mocked RPC responses (zero,
  large values, RPC errors, HTTP errors, malformed results)

### Design Decisions

- Derivation path `m/44'/60'/0'/0/0` (Ethereum coin type 60) follows
  the default of Flare's official `flare-stake-tool`, and the C-Chain
  address space matches Ethereum's (20-byte ECDSA addresses), as stated
  on dev.flare.network's Network page
- Addresses use EIP-55 checksum casing, the Ethereum convention for
  mixed-case addresses; it is an interoperability choice, not a Flare
  requirement
- The network is a required parameter of `fromMnemonic`: the address is
  identical on every Flare network, but balances (and later the signing
  chain ID) are not, so there is no silent default network
- The private key has no getter and never leaves `LocalWallet`
- Invalid mnemonics throw `FlareException` (user input); out-of-range
  indexes throw `RangeError` (programmer error)
- An optional `JsonRpcClient` can be injected for tests, following the
  same pattern as `ContractRegistryClient`; a client targeting a
  different network than the wallet is rejected

### Status

M1 in progress: network foundation, Contract Registry client, and local
wallet key derivation and balance complete and tested.  
Not ready for production use.  
Next: P-Chain address derivation (`0.0.5-dev`).

## 0.0.3-dev

M1 in progress: Contract Registry client implemented and verified
against the official FlareContractRegistry specification.

### Added

- `JsonRpcClient` (`network/`): shared JSON-RPC 2.0 transport over
  HTTPS, used by every module that reads from or writes to a Flare
  network
- `ContractRegistryClient.getContractAddress()`: resolves official
  contract addresses via the FlareContractRegistry
  (`0xaD67FE66660Fb8dFE9d6b1b4240d8650e30F6019`), verified against
  dev.flare.network's JS, Go, and FAssets integration guides
- Hand-rolled ABI encoding/decoding for
  `getContractAddressByName(string)`, no external EVM library
  dependency
- 3 unit tests with mocked HTTP responses, covering a successful
  resolution, an unregistered contract name, and a non-200 HTTP
  response

### Design Decisions

- Chose to hand-encode the ABI call instead of adding a generic EVM
  library dependency, keeping the SDK's dependency surface intentional
  rather than pulling in a full library for one function call
- The registry returns the zero address instead of reverting for an
  unknown contract name, so `getContractAddress` checks for it
  explicitly and throws `FlareException` rather than returning an
  invalid address silently

### Status

M1 in progress: network foundation and Contract Registry client
complete and tested. Local wallet is next.  
Not ready for production use.  
Next: `LocalWallet` key derivation (`0.0.4-dev`).

## 0.0.2-dev

M1 in progress: network foundation implemented and verified against
official RPC endpoints and chain IDs.

### Added

- `NetworkConfig.forNetwork()`: resolves the official RPC URL, chain
  ID, and native currency symbol for each of the four Flare networks
  (Flare, Songbird, Coston2, Coston), sourced from
  dev.flare.network's Network Configuration page
- `currencySymbol` field added to `NetworkConfig`
- 5 unit tests covering each network's resolved values and chain ID
  uniqueness across all four networks

### Status

M1 in progress: network foundation complete and tested. Contract
Registry client is next.  
Not ready for production use.  
Next: `ContractRegistryClient.getContractAddress` (`0.0.3-dev`).

## 0.0.1-dev

Scaffold phase complete: project structure, tooling, and CI pipeline in
place. No functional API yet, every public method is an intentional
`UnimplementedError` skeleton matching the planned v1.0.0 surface.

### Added

- Package scaffold via `flutter create --template=package`
  (org `com.nemorixpay`), reserving `flare_flutter_sdk` on pub.dev
- Module structure defined, one directory per Flare protocol boundary:
  `network/`, `registry/`, `wallet/`, `transactions/`, `ftso/`,
  `fassets/`, `fdc/`, `exceptions/`
- `FlareNetwork`: enum for the four supported networks (Flare, Songbird,
  Coston2, Coston)
- `FlareException`: base exception type for all SDK errors
- `NetworkConfig` and `ContractRegistryClient`: skeletons for the
  FlareContractRegistry directory pattern (M1)
- `Wallet` interface, `LocalWallet`, `WalletConnectController`:
  wallet abstraction skeletons (M1)
- `TransactionBuilder`: native/ERC-20 transfer and contract call
  skeleton (M2)
- `FeedCategory`, `FeedId`, `FtsoClient`, `FtsoFeed`: FTSOv2 price feed
  client skeleton, including the feed-ID encoding helper (M3)
- `FAssetsClient`: FXRP mint/redeem flow skeleton (M4)
- `FdcAttestationType`, `FdcClient`: minimum FDC attestation support
  skeleton for AddressValidity, Payment, and EVMTransaction (M4)
- 3 unit tests covering `FlareNetwork` enum completeness and
  `FlareException` message formatting
- `example/flare_flutter_sdk_example.dart`: illustrative usage of the
  planned v1.0.0 API (wallet connection, FTSO feed read)
- CI pipeline (GitHub Actions): format, analyze, test, coverage check,
  `pub publish --dry-run`, and a Coston2 integration job
- `CONTRIBUTING.md`: development setup, branch strategy, commit
  conventions, testing standards, and security policy

### Changed

- `analysis_options.yaml`: configured to extend `very_good_analysis`
  (replacing the default `flutter_lints` generated by `flutter create`)

### Design Decisions

- Pinned `pointycastle` to `^3.9.0` and `reown_walletkit` to `^1.0.3`
  to resolve a dependency conflict: `bip32` does not yet support
  `pointycastle ^4.0.0`, which `reown_walletkit >=1.3.9` requires.
  Revisit once `bip32` (or a replacement) supports `pointycastle ^4.x`
- CI coverage threshold temporarily lowered to 5% during the scaffold
  phase; returns to the 80% target once M1 lands with real coverage
- Module boundaries mirror Flare's own protocol boundaries (FTSO,
  FAssets, FDC) rather than a generic wallet-first structure, so each
  milestone maps cleanly to one directory

### Status

Scaffold complete: structure, tooling, and CI are in place.  
No network interaction yet (that begins in M1).  
Not ready for production use.  
Next: network foundation, Contract Registry, and wallet abstraction
(M1).
