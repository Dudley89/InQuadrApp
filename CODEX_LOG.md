# CODEX_LOG

## Stato release
- Versione corrente: **V3 (contenuti locali/offline + camera live preview)**
- Stato: **In sviluppo, validazione runtime completa demandata ad ambiente con SDK Flutter**

## Decisioni prese
- Stack V1: Flutter + Riverpod + go_router + permission_handler.
- Separazione iniziale tra app shell (`lib/app`) e feature (`lib/features/*`).
- Permessi camera gestiti senza plugin `camera` in V1, solo stato/richiesta.
- Logging centralizzato con wrapper su `debugPrint` e livelli `info/warn/error`.
- Tema light/dark condiviso con Material 3 e componenti base customizzati.
- V3 adotta dataset monumenti locale statico con repository dedicato per abilitare uso offline.

## Domande aperte
- Definire naming definitivo del brand: `InQuadra` resta nome finale o solo provvisorio?
- Confermare set di contenuti minimi definitivo della scheda monumento post-V3 (campi obbligatori).
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
1. Eseguire validazione completa locale/CI con SDK Flutter disponibile (`flutter pub get`, `flutter analyze`, `flutter test`, `flutter run`).
2. Rigenerare/normalizzare scaffold nativo con `flutter create .` mantenendo custom code per allineamento ai template ufficiali.
3. Aggiungere test dedicati a `CameraPermissionController`, stati UI `CameraScreen` e dettaglio monumento dinamico.
4. Progettare V4: integrazione riconoscimento monumenti + backend contenuti.
5. Definire specifica accessibilità avanzata e audio guida reale (V5 roadmap).

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


### Iterazione 2026-02-19 (V2 camera live preview)
- Integrata dipendenza `camera` in `pubspec.yaml` e introdotto `camera_preview_controller.dart` con inizializzazione/dispose del `CameraController` via Riverpod.
- Evoluta `CameraScreen` con preview reale (`CameraPreview`) quando permesso concesso, loading/error state e CTA `Simula riconoscimento` abilitata solo con permesso `granted`.
- Raffinata UX permessi con branch dedicati per stati `denied`, `permanentlyDenied` e `restricted`, inclusa azione `Apri impostazioni`.
- Aggiunta gestione errori nel `CameraPermissionController` per fallback sicuro in assenza plugin/runtime issues.
- Aggiornati `.gitignore` (incluso `android/.gradle/`) e `README.md` a stato V2.
- Validazione automatica completa non eseguita in ambiente corrente per assenza SDK Flutter.

### Iterazione 2026-02-19 (hotfix toolchain Android per CameraX)
- Aggiornata versione Android Gradle Plugin in `android/settings.gradle` da `8.3.2` a `8.6.0` per compatibilità con dipendenze CameraX (`androidx.camera:*:1.5.3`).
- Aggiornata versione Kotlin plugin in `android/settings.gradle` da `1.9.24` a `2.1.0` per allineamento ai warning Flutter tooling.
- Aggiunto `android/gradle/wrapper/gradle-wrapper.properties` con Gradle `8.7` (distributionUrl) per soddisfare il requisito minimo segnalato in build.
- Nessuna modifica funzionale alla logica app Flutter; fix mirato al build toolchain Android.
- Build/test automatici non eseguiti in questo ambiente per assenza SDK Flutter.


### Iterazione 2026-02-19 (V3 contenuti monumenti locali)
- Introdotti modello dominio (`Monument`), dataset locale statico e repository feature monuments per contenuti offline.
- Aggiunta schermata `MonumentsListScreen` con elenco monumenti locali e navigazione al dettaglio dinamico (`/monument/:id`).
- Rifattorizzata `MonumentDetailScreen` per leggere contenuti locali via provider Riverpod in base all'ID route.
- Aggiornati routing e entrypoint di navigazione: Home apre la lista monumenti, Camera simula riconoscimento verso monumento featured locale.
- Aggiunto file root `VERSION_MATRIX.md` con definizione centralizzata delle versioni release/dependency/toolchain.
- Aggiornati `README.md` a stato V3 e test widget con verifica navigazione Home -> Monumenti lista.
- Validazione test/build Flutter non eseguibile in questo ambiente per assenza SDK (`flutter: command not found`).
