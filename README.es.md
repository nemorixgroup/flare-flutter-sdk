[![pub package](https://img.shields.io/pub/v/flare_flutter_sdk.svg)](https://pub.dev/packages/flare_flutter_sdk)
[![license: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)


[English](README.md) | **Español**  

# flare_flutter_sdk

**El primer SDK nativo de Flutter/Dart para la red Flare.**

> **Estado: Desarrollo Temprano** - La API no es estable.
> M1 (Fundación & Wallet) en progreso. Ver
> [CHANGELOG.md](CHANGELOG.md) para más detalles.

---

## Por qué flare_flutter_sdk

El tooling oficial de desarrolladores de Flare cubre TypeScript (el
[flare-tx-sdk](https://dev.flare.network/network/flare-tx-sdk) oficial), además
de guías de lenguaje para Python, Go, y Rust. Dart, el lenguaje detrás de Flutter,
no tiene cobertura hoy. `flare_flutter_sdk` cierra esa brecha con una
implementación pura en Dart, sin platform channels, para iOS, Android, macOS,
Windows, Linux, y Web.

## Funcionalidades Planeadas (v1.0.0)

- **Fundación de red**: soporte multi-red (Flare, Songbird, Coston2,
  Coston) vía el patrón de directorio `FlareContractRegistry`
- **Abstracción de wallet**: WalletConnect/EIP-1193 y wallets de llave local, con
  derivación de direcciones C-Chain y P-Chain
- **Transacciones core**: transferencias nativas y ERC-20, llamadas a contratos
- **FTSO**: consumo de price feeds en vivo vía FTSOv2 (`getFeedById`,
  `getFeedsById`), con un helper de feed ID para que nunca tengas que codificar uno a mano
- **FAssets**: flujo completo de mint y redeem de FXRP, respaldado por los tipos
  de atestación FDC que el flujo requiere (AddressValidity, Payment,
  EVMTransaction)

## Documentación y Knowledge Base

Este SDK está construido sobre la base del [Flare Knowledge Base](https://github.com/nemorixgroup/Flare-Knowledge-Base), una guía a fondo de la red Flare
que cubre consenso, arquitectura, Flare Data Connector, ecosistema de desarrollo, casos de uso, etc. Lectura recomendada
antes de profundizar en el funcionamiento interno del SDK.

Cada decisión de implementación detrás de este SDK, elección de librerías,
estándares de encoding, verificación contra las especificaciones oficiales, está
documentada en [docs-sdk/](https://github.com/nemorixgroup/Flare-Knowledge-Base/blob/main/docs-sdk/README.md).

## Instalación

```yaml
# pubspec.yaml
dependencies:
  flare_flutter_sdk: ^0.0.3-dev
```

```bash
flutter pub get
```

## Inicio Rápido

```dart
import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';

Future<void> main() async {
  // Resuelve la configuración de red (funciona hoy)
  final config = NetworkConfig.forNetwork(FlareNetwork.coston2);
  print('Connected to chain ID ${config.chainId} via ${config.rpcUrl}');

  // Resuelve una dirección de contrato oficial vía el Contract Registry
  // (funciona hoy, hace una llamada RPC real)
  final registry = ContractRegistryClient(config);
  final wNatAddress = await registry.getContractAddress('WNat');
  print('WNat address on Coston2: $wNatAddress');
}
```

> El ejemplo de arriba corre hoy contra Coston2. Wallets, transacciones,
> FTSO, y FAssets siguen en progreso.

## Roadmap

| Milestone | Alcance | Estado |
|---|---|---|
| M1 | Fundación de red, Contract Registry, abstracción de wallet | 🔄 En Progreso |
| M2 | Transacciones core (nativas + ERC-20, llamadas a contratos) | ⏳ Planeado |
| M3 | Cliente de price feed FTSO | ⏳ Planeado |
| M4 | FAssets (FXRP) mint/redeem + soporte mínimo de FDC | ⏳ Planeado |
| M5 | Tests, docs, ejemplos, release v1.0.0 en pub.dev | ⏳ Planeado |

## Contribuir

Las contribuciones son bienvenidas una vez que la arquitectura core de M4 esté lista. Ver
[CONTRIBUTING.md](CONTRIBUTING.md) para setup de desarrollo, estrategia de branches,
y estándares de código.

## Licencia

Licenciado bajo la [Apache License 2.0](LICENSE).

## Para desarrolladores de LATAM

Este SDK se está desarrollando con soporte nativo para la región en mente:

- Documentación bilingüe (inglés / español) desde el primer módulo.
- Parte del ecosistema de SDKs de Nemorix Group para infraestructura financiera
  en LATAM (Hedera, Avalanche, XRPL, Flare).
- Desarrollado por [Nemorix Group](https://nemorixpay.com), Ohio, USA.

Síguenos para novedades: **sdks@nemorixpay.com**

## Enlaces

- Paquete: [pub.dev/packages/flare_flutter_sdk](https://pub.dev/packages/flare_flutter_sdk)
- Flare Developer Hub: [dev.flare.network](https://dev.flare.network)
- Nemorix Group: [nemorixpay.com](https://nemorixpay.com)
- Contacto: sdks@nemorixpay.com

## Apoya Este Proyecto

Si este SDK te es útil a ti o a tu equipo, considera apoyar su
desarrollo. Cada contribución ayuda a cubrir infraestructura,
documentación, y el tiempo invertido en construir y mantener esta
herramienta open source para la red Flare y la comunidad de Flutter. ¡Gracias!

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/nemorixgroupllc)
[![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/nemorixgroup)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5F5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/nemorixgroupllc)

---

Construido por [Nemorix Group](https://nemorixpay.com) · Apache 2.0
