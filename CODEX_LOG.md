# CODEX_LOG

## Stato release
- Versione corrente: **V1 (bootstrap completo)**
- Stato: **In sviluppo, base pronta per iterazioni successive**

## Decisioni prese
- Stack V1: Flutter + Riverpod + go_router + permission_handler.
- Separazione iniziale tra app shell (`lib/app`) e feature (`lib/features/*`).
- Permessi camera gestiti senza plugin `camera` in V1, solo stato/richiesta.
- Logging centralizzato con wrapper su `debugPrint` e livelli `info/warn/error`.
- Tema light/dark condiviso con Material 3 e componenti base customizzati.

## Domande aperte
- Definire naming definitivo del brand: `InQuadra` resta nome finale o solo provvisorio? NOTA DEL 19/02/2026: PROVVISORIO.
- Confermare set di contenuti minimi della scheda monumento in V2 (campi obbligatori).
- Decidere strategia accessibilità dettagliata (font scaling custom vs sola impostazione OS).

## Problemi rilevati
- Ambiente corrente senza SDK Flutter disponibile (`flutter: command not found`), quindi build e test non eseguiti localmente in questa iterazione.
- File nativi Android/iOS creati in forma minima; da validare con `flutter create`/tooling ufficiale appena disponibile SDK.

## Cosa fatto (changelog per iterazione)

### Iterazione 2026-02-19 (V1 bootstrap)
- Creata struttura progetto Flutter-base con `pubspec.yaml` e `analysis_options.yaml`.
- Implementata app shell:
  - `MaterialApp.router`
  - tema light/dark coerente
  - routing con go_router (`/`, `/camera`, `/monument`)
- Implementate schermate placeholder:
  - Home con CTA "Avvia fotocamera" e "Monumenti"
  - Camera con area preview finta + stato permesso
  - Monument detail con sezioni richieste (approfondisci/audio/accessibilità)
- Implementata gestione permessi camera con Riverpod + permission_handler.
- Aggiunta utility logger e log su avvio app, navigazione, stato permessi.
- Aggiunti test widget minimi:
  - rendering Home
  - navigazione Home -> Camera
- Aggiornato `README.md` con requisiti, run/test, roadmap, policy `CODEX_LOG.md`.
- Aggiunte configurazioni base permessi:
  - `android/app/src/main/AndroidManifest.xml` con CAMERA
  - `ios/Runner/Info.plist` con `NSCameraUsageDescription`

## Prossimi passi
1. Installare/configurare Flutter SDK nell'ambiente CI/dev e validare `flutter pub get`, `flutter analyze`, `flutter test`, run Android/iOS.
2. Rigenerare scaffold nativo con `flutter create .` mantenendo custom code, per allineamento completo ai template ufficiali.
3. Raffinare UX stato permessi (gestione denied/permanentlyDenied/restricted con call-to-action dedicate).
4. Introdurre test aggiuntivi su schermata MonumentDetail e stati del permission controller.
5. Preparare V2 con integrazione plugin `camera` e preview reale.

### Iterazione 2026-02-19 (hotfix compatibilità ThemeData)
- Corretto errore di tipo Flutter: sostituito `CardTheme` con `CardThemeData` in `lib/app/theme.dart` per compatibilità con la firma `ThemeData.cardTheme`.
- Verifica locale in questo ambiente non eseguibile per assenza SDK Flutter (`flutter: command not found`).

### Iterazione 2026-02-19 (hotfix PermissionStatus)
- Corretto errore API `PermissionStatus`: rimosso uso del getter `isGranted` e sostituito con confronto esplicito `== PermissionStatus.granted`.
- Aggiornata `CameraScreen` con import `permission_handler` e condizione esplicita `permissionStatus != PermissionStatus.granted`.
- Validazione runtime/test bloccata in questo ambiente per assenza SDK Flutter.

### Iterazione 2026-02-19 (hotfix Android embedding v2)
- Risolto errore build Android "deleted Android v1 embedding" creando entrypoint Android moderno (`MainActivity` con `io.flutter.embedding.android.FlutterActivity`).
- Aggiornato `AndroidManifest.xml` con metadata `flutterEmbedding=2` e `NormalTheme`.
- Aggiunti file Gradle Android minimi compatibili con plugin Flutter moderno: `android/settings.gradle`, `android/build.gradle`, `android/gradle.properties`, `android/app/build.gradle`.
- Aggiunte risorse tema Android minime (`styles.xml`, `launch_background.xml`) per coerenza manifest.
- Nota: validazione build Android non eseguita qui per assenza SDK Flutter.

### Iterazione 2026-02-19 (lint fix const constructors MonumentDetail)
- Risolti warning `prefer_const_constructors` e `prefer_const_literals_to_create_immutables` in `MonumentDetailScreen` rendendo const i blocchi `Card`/`Padding`/`Column`/`Row` e relativi widget figli immutabili.
- Nessuna modifica funzionale ai comportamenti UI: solo ottimizzazioni lint/performance.
- Validazione automatica locale ancora bloccata per assenza SDK Flutter nell'ambiente.

### Iterazione 2026-02-19 (hotfix Android launcher icon mancante)
- Risolto errore AAPT `resource mipmap/ic_launcher not found` aggiungendo risorsa `android/app/src/main/res/mipmap/ic_launcher.xml`.
- Impostata icona launcher minima basata su `@android:drawable/sym_def_app_icon` per ripristinare compilazione resource-linking.
- Nessuna modifica funzionale all'app Flutter; fix limitato allo scaffold Android.
- Validazione build completa non eseguita in questo ambiente per assenza SDK Flutter.

### Iterazione UMANA 2026-02-19 test manuali
- test manuali effettuati con successo;
- è possibile proseguire con la V2.
