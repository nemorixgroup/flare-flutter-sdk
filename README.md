# flare_flutter_sdk
 
**The first native Flutter/Dart SDK for the Flare Network.**
 
[![pub package](https://img.shields.io/pub/v/flare_flutter_sdk.svg)](https://pub.dev/packages/flare_flutter_sdk)
[![license: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
 
> **Status: early development (v0.0.1-dev).** See [Roadmap](#roadmap) below for the release plan. Star or watch this repository to follow progress.
 
---
 
## Why flare_flutter_sdk
 
Flare's official developer tooling covers TypeScript (the official
[flare-tx-sdk](https://dev.flare.network/network/flare-tx-sdk)), plus
language guides for Python, Go, and Rust. Dart, the language behind Flutter,
has no coverage today. `flare_flutter_sdk` closes that gap with a pure Dart
implementation, no platform channels, for iOS, Android, macOS, Windows,
Linux, and Web.
 
## Planned Features (v1.0.0)
 
- **Network foundation**: multi-network support (Flare, Songbird, Coston2,
  Coston) via the `FlareContractRegistry` directory pattern  
- **Wallet abstraction**: WalletConnect/EIP-1193 and local key wallets, with
  C-Chain and P-Chain address derivation  
- **Core transactions**: native and ERC-20 transfers, contract calls  
- **FTSO**: live price feed consumption via FTSOv2 (`getFeedById`,
  `getFeedsById`), with a feed ID helper so you never hand-encode a feed ID  
- **FAssets**: end-to-end FXRP mint and redeem flow, backed by the FDC
  attestation types the flow requires (AddressValidity, Payment,
  EVMTransaction)  

## Quick Start (planned API, subject to change before v1.0.0)
 
```yaml
dependencies:
  flare_flutter_sdk: ^0.0.1-dev
```
 
```dart
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
 
Future<void> main() async {
  final client = FlareClient(network: FlareNetwork.coston2);
 
  // Connect a wallet
  final wallet = await LocalWallet.fromMnemonic(myMnemonic);
 
  // Read a live FTSO price feed
  final feed = await client.ftso.getFeedById(
    FeedId.fromName(category: FeedCategory.crypto, name: 'FLR/USD'),
  );
  print('FLR/USD: ${feed.value}');
}
```
 
## Roadmap
 
| Milestone | Scope | Status |
|---|---|---|
| M1 | Network foundation, Contract Registry, wallet abstraction | Planned |
| M2 | Core transactions (native + ERC-20, contract calls) | Planned |
| M3 | FTSO price feed client | Planned |
| M4 | FAssets (FXRP) mint/redeem + minimum FDC support | Planned |
| M5 | Tests, docs, examples, v1.0.0 release on pub.dev | Planned |
 
 
## Documentation
 
A bilingual (Spanish/English) knowledge base accompanies this SDK; the
English README here is the canonical quick-start reference, with deeper
technical write-ups published as the corresponding milestones land.
 
## Contributing
 
Contributions are welcome once the core architecture from M1 lands. See
[CONTRIBUTING.md](CONTRIBUTING.md) for development setup, branch strategy,
and code standards.
 
## License
 
Licensed under the [Apache License 2.0](LICENSE).
 
## Links
 
- Package: [pub.dev/packages/flare_flutter_sdk](https://pub.dev/packages/flare_flutter_sdk)
- Flare Developer Hub: [dev.flare.network](https://dev.flare.network)
- Nemorix Group: [nemorixpay.com](https://nemorixpay.com)
- Contact: sdks@nemorixpay.com

## Support This Project

If this SDK is useful to you or your team, consider supporting its
development. Every contribution helps cover infrastructure,
documentation, and the time invested in building and maintaining this
open source tool for the Avalanche and Flutter community. Thank you!

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/nemorixgroupllc)
[![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/nemorixgroup)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5F5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/nemorixgroupllc)

---

<p align="center">
  <sub>Built by <a href="https://nemorixpay.com">Nemorix Group</a>
  · Apache 2.0</sub>
</p>
