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

### Iterazione 2026-02-19 (V3.1 navigazione back-stack UX)
- Corretto comportamento navigazione usando `context.push` (invece di `go`) nei flussi Home -> Fotocamera, Home -> Monumenti, Monumenti -> Scheda e Fotocamera -> Scheda per preservare lo stack e il tasto indietro nativo.
- Rimossa CTA in fondo alla `MonumentDetailScreen` (`Torna alla fotocamera`) come richiesto: il ritorno avviene ora tramite back nativo.
- Aggiunti test widget per verificare il back stack: `Back da Camera torna a Home` e `Back da dettaglio monumento torna a lista Monumenti`.
- Nessuna modifica alla business logic dei contenuti; intervento focalizzato su UX di navigazione.
- Validazione automatica Flutter bloccata in questo ambiente (`flutter: command not found`).

### Iterazione 2026-02-19 (V3.2 contenuti Tagliacozzo)
- Sostituito integralmente il dataset locale monumenti con i contenuti forniti per Tagliacozzo (`Obelisco`, `Chiostro del Convento di San Francesco`, `Statua di Dante Alighieri`) mantenendo invariata la struttura dati (`id`, `name`, `description`, `deepDive`, `accessibility`).
- Nessuna modifica a routing, UI o logica applicativa: aggiornamento solo contenutistico.
- Verifica automatica Flutter non eseguibile in questo ambiente per assenza SDK (`flutter: command not found`).

### Iterazione 2026-02-19 (V3.3 mappa monumenti e vicinanze)
- Esteso il modello `Monument` con coordinate geografiche (`latitude`, `longitude`) e aggiornato il dataset locale Tagliacozzo con lat/lon per ciascun punto d’interesse.
- Migliorata `MonumentDetailScreen` con mappa OpenStreetMap (`flutter_map`) centrata sul monumento selezionato e marker per tutti i monumenti locali.
- Aggiunta sezione “Monumenti vicini” calcolata da coordinate (raggio <= 1 km) tramite `latlong2`.
- Aggiornati `pubspec.yaml`, `README.md`, `VERSION_MATRIX.md` e i test widget (stringhe dataset aggiornate: `Obelisco`).
- Validazione Flutter non eseguita in questo ambiente per assenza SDK (`flutter: command not found`).

### Iterazione 2026-02-19 (V3.4 mappa stradale utile + interazione marker)
- Ridotto il raggio dei “Monumenti vicini” da 1km a 200m e inserita nota esplicita in UI per ricordare la calibrazione (troppo poco/troppo alto) dopo test reali.
- Abilitata posizione utente in `MonumentDetailScreen` tramite `geolocator` (richiesta permesso runtime; marker verde `my_location` su mappa quando disponibile).
- Aggiunte dipendenze/permessi per funzionalità mappa utile: `geolocator` in `pubspec.yaml`, permessi `INTERNET` + location in AndroidManifest, `NSLocationWhenInUseUsageDescription` in Info.plist.
- Migliorata interazione marker: tap su marker mostra card con nome monumento, distanza dall’utente e pulsante per aprire la scheda del monumento selezionato.
- Rafforzata UX mappa con dicitura chiara “mappa stradale OpenStreetMap” e sezione vicinanze a 200m.
- Validazione Flutter non eseguita in questo ambiente per assenza SDK (`flutter: command not found`).

### Iterazione 2026-02-19 (V3.5 richieste permessi allo start)
- Introdotto `StartupPermissionRequester` in app shell per richiedere all'avvio i permessi di camera e posizione (`locationWhenInUse`).
- Integrato il requester nel `builder` di `MaterialApp.router` per esecuzione globale allo startup senza bloccare la UI.
- Gestiti errori di richiesta permessi con logging e fallback sicuro: in caso di permessi negati/rimossi l'app non crasha e continua a funzionare mostrando stati degradati.
- Mantenute le richieste on-demand nei flussi feature (camera/location) quando necessario.
- Aggiornato `README.md` con nota esplicita sulla strategia permessi startup + fallback.

### Iterazione 2026-02-19 (V3.6 controllo internet startup)
- Aggiunto controllo connettività internet allo startup (Wi-Fi/dati) in `StartupPermissionRequester` tramite `connectivity_plus`, con log informativo/warning e fallback non bloccante.
- Esteso il perimetro startup check: camera + posizione + connettività, mantenendo comportamento anti-crash in caso di errori/permessi negati/assenza rete.
- Aggiornata configurazione Android con `ACCESS_NETWORK_STATE` oltre a `INTERNET` per verificare stato rete.
- Aggiornati `pubspec.yaml`, `README.md` e `VERSION_MATRIX.md` per tracciare dipendenza e policy connettività.

### Iterazione 2026-02-19 (V3.7 idGlobal + immagini monumenti)
- Esteso il modello `Monument` con `idGlobal` (intero) per supportare chiave univoca lato DB.
- Aggiunto `imageUrl` nel modello/dataset locale e popolati i link immagine richiesti per i tre monumenti di Tagliacozzo.
- Aggiornata `MonumentDetailScreen` per mostrare l'immagine via `Image.network` con fallback grafico in caso di errore caricamento.
- Mostrato `ID globale` in scheda monumento per facilitare verifica e allineamento con future integrazioni backend.
- Aggiornati `README.md` e `VERSION_MATRIX.md` con i nuovi campi dati del modello.

### Iterazione 2026-02-21 (V3.8 icona applicazione)
- Aggiornate le risorse icona app su Android e iOS partendo da un asset comune (`assets/icons/app_icon.png`).
- Android: sostituita la risorsa launcher con `android/app/src/main/res/mipmap/ic_launcher.png` e rimossa la vecchia definizione XML non più necessaria.
- iOS: rigenerato l'intero set `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` con relativo `Contents.json` coerente con le dimensioni richieste da Xcode.
- Nessuna modifica alla logica applicativa Flutter; intervento limitato alle risorse grafiche native.
- Verifica runtime Flutter non eseguibile in questo ambiente per assenza SDK (`flutter: command not found`).

### Iterazione 2026-02-21 (V3.9 patch senza file binari)
- Rimossi dalla patch tutti i file binari PNG delle icone (`android`/`assets`/`ios AppIcon.appiconset`) per rispettare il vincolo di PR testuale.
- Android: mantenuto `AndroidManifest.xml` su `@mipmap/ic_launcher` e aggiunti `mipmap-anydpi-v26/ic_launcher.xml` + `ic_launcher_round.xml` (solo XML) con drawables di sistema.
- iOS: mantenuto solo `Contents.json` nell'asset catalog AppIcon, senza riferimenti a file PNG versionati.
- Aggiornato `.gitignore` per evitare il reinserimento accidentale di asset icona PNG in commit futuri.

### Iterazione 2026-02-21 (V4 UX permessi/back/mappa)
- Home: intercettato il tasto indietro con popup di conferma "Sei sicuro di uscire?"; con "Sì" l'app si chiude, con "No" (o chiusura popup) si resta in app.
- Startup permessi: controllo combinato camera + posizione + connettività (Wi-Fi/dati); se uno dei requisiti manca viene mostrato il popup "Autorizzazioni necessarie per far funzionare l'applicazione.".
- Android: dopo il popup viene aperta la schermata impostazioni app (`openAppSettings`); al rientro in foreground (`AppLifecycleState.resumed`) il controllo viene rieseguito.
- Scheda Monumento: la card del marker selezionato è stata spostata DENTRO la mappa (overlay) e mostra nome + "Distanza" calcolata tra monumento in scheda e marker selezionato.
- Mappa: limitato lo zoom out con `minZoom` per mantenere una vista massima circa entro 1km di raggio attorno al monumento.

### Iterazione 2026-02-21 (V4.1 overlay prossimità + startup gate bloccante)
- Refactor startup: introdotti `StartupRequirementsChecker` (servizio) e `StartupGate` (widget) con flusso **check-first** (nessuna richiesta permessi immediata) per verificare internet, servizio posizione, permesso posizione, permesso camera.
- Dialog bloccante (`barrierDismissible: false`) con titolo `Permessi necessari`, elenco puntato requisiti mancanti e azioni `Apri impostazioni` / `Esci`.
- Loop di ricontrollo al rientro in app (`WidgetsBindingObserver` + `AppLifecycleState.resumed`): se i requisiti restano mancanti il dialog viene mostrato di nuovo.
- Gestione uscita piattaforma-specifica: Android chiude con `SystemNavigator.pop()`, iOS mostra messaggio informativo (chiusura forzata non supportata).
- Scheda Monumento (mappa): aggiunto overlay "Prossimo punto vicino" visibile **solo dopo interazione utente** (tap sulla mappa); al primo caricamento non appare nulla.
- Decisione UX sui conflitti overlay/marker: scelta **A** → tap su marker mostra solo card marker e nasconde overlay "prossimo punto" per evitare doppio pannello sovrapposto.
- Overlay prossimità migliorato con Material 3 (`Card`, icone, spacing), chiusura con pulsante X e animazioni `AnimatedSlide` + `AnimatedOpacity`.
- Distanza overlay: usa posizione utente se disponibile; fallback su monumento corrente con messaggio esplicito quando la posizione non è disponibile.
- Test: aggiornati widget test con checker fittizio via provider override (caso requisiti OK + caso requisiti mancanti con dialog bloccante).
- Criticità ambiente: SDK Flutter/Dart assente, quindi impossibile eseguire `flutter test` localmente in questo container.

### Iterazione 2026-02-21 (V4.2 startup gate route-first + fix navigator context)
- Root cause crash: il flusso precedente mostrava dialog/azioni da un widget wrapper nel `builder` globale di `MaterialApp.router`, con casi in cui il `BuildContext` non era ancora sotto un `Navigator` valido → errore runtime: `Navigator operation requested with a context that does not include a Navigator`.
- Fix architetturale: rimossa la logica di gating dal wrapper globale e introdotta route dedicata `/startup` (`StartupGateScreen`) come primo entrypoint del router (`initialLocation`), così ogni navigazione avviene dentro il tree gestito da `go_router`.
- Navigazione sicura: transizione verso Home solo via `context.go('/home')` da `StartupGateScreen` dopo check positivi; nessuna navigazione avviata da service/singleton o da contesto fuori router.
- Requisiti hard implementati in gate screen:
  - Internet attivo (Wi-Fi/mobile) via `connectivity_plus`.
  - Servizi posizione attivi (GPS) via `Geolocator.isLocationServiceEnabled`.
  - Permesso posizione e fotocamera via `permission_handler` (con richiesta runtime e fallback `openAppSettings` se permanently denied).
- UI gate: schermata dedicata con card stato requisito, azioni mirate (`Apri impostazioni rete`, `Apri impostazioni posizione`, `Concedi permesso`), pulsante `Retry` e `Esci`.
- Loop ricontrollo: ri-verifica automatica al resume (`WidgetsBindingObserver`) dopo ritorno dalle impostazioni.
- Nota piattaforma: su Android `Esci` usa `SystemNavigator.pop()`, su iOS viene mostrato messaggio informativo (chiusura forzata non supportata).
- Test aggiornati: widget test con checker fake via provider override per validare rendering dello startup gate e scenario requisito mancante.
- Vincolo ambiente: in questo container non sono presenti Flutter/Dart SDK, quindi impossibile eseguire `flutter test` / run reale per validazione runtime emulator/device.
