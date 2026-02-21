# VERSION_MATRIX

## App release versions
- V1: bootstrap Flutter, routing base, tema, placeholder schermate, permessi camera (richiesta/stato)
- V2: camera live preview + UX permessi avanzata
- V3: contenuti monumenti locali/offline (dataset locale + lista monumenti + dettaglio dinamico)

## Dependency versions (pubspec)
- flutter_riverpod: ^2.5.1
- go_router: ^14.2.0
- permission_handler: ^11.3.1
- camera: ^0.11.0+2
- flutter_lints: ^4.0.0

## Android toolchain versions
- Android Gradle Plugin (AGP): 8.6.0
- Kotlin Android plugin: 2.1.0
- Gradle wrapper: 8.7

## iOS configuration
- NSCameraUsageDescription presente in `ios/Runner/Info.plist`

## Note gestione versioni
- Aggiornare questo file a ogni iterazione quando cambia una versione di release, dipendenza o toolchain.
