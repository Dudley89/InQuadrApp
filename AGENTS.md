# Istruzioni operative per InQuadra

Leggere `REQUIREMENTS.md` e almeno le ultime tre iterazioni di `CODEX_LOG.md`
prima di iniziare una modifica.

## Ambiente e verifiche

- Il target di sviluppo principale è Android su dispositivo fisico. iOS non è
  compilabile sulla macchina di sviluppo Windows: non modificare `ios/` se non
  richiesto esplicitamente.
- Prima di chiudere una modifica eseguire, nell'ordine, `flutter analyze` e
  `flutter test`. Correggere gli errori e ripetere i controlli; se non passano
  dopo due tentativi, fermarsi e documentare il problema.
- Per diagnosticare errori runtime usare `adb logcat -c` prima della
  riproduzione e poi `adb logcat -d` (oppure `adb logcat -d -s flutter`). Non
  reindirizzare l'output di `flutter run`, per non interrompere l'hot reload.
- Aggiornare sinteticamente `CODEX_LOG.md` al termine di ogni iterazione con
  lavoro svolto, problemi, decisioni e prossimi passi.

## Vincoli tecnici

- Usare Riverpod 2.x con le API esistenti; non migrare a Riverpod 3 senza una
  richiesta esplicita.
- Usare `go_router` per il routing e `flutter_map` con OpenStreetMap per le
  mappe; non introdurre Google Maps.
- Non aggiungere, aggiornare o retrocedere dipendenze senza conferma esplicita.
  Ogni modifica a `pubspec.yaml` deve essere seguita da `flutter pub get` e
  `flutter analyze`.
- Rispettare la struttura esistente: bootstrap, router, tema e shell in
  `lib/app/`; funzionalita in `lib/features/`; logging e widget condivisi in
  `lib/shared/`. Non spostare codice o creare nuove cartelle a questi livelli
  senza motivo.
- Estendere il riconoscimento tramite `MonumentRecognizer`, senza riscrivere
  `ScanController` e la sua logica di throttling, busy gating, streak e lock.

## Comportamenti da preservare

- Avvio diretto su `/home` e permessi richiesti on demand.
- Stop e riavvio dello scan legati al ciclo di vita della route.
- Card di conferma del riconoscimento con azioni `Apri dettagli` e `Riprova`,
  senza navigazione automatica.
- Cancellazione dei file temporanei di `takePicture()` nel blocco `finally` e
  feedback aptico al lock.
- Campi `idGlobal`, `deepDive` e `accessibility` del modello `Monument`.

## Stile di lavoro

- Affrontare un task alla volta con modifiche minime e mirate; non
  riformattare file estranei al task.
- Per decisioni architetturali non banali, presentare prima un piano e
  attendere approvazione.
- Usare un commit Git per iterazione. Se una richiesta contraddice queste
  istruzioni o `REQUIREMENTS.md`, segnalarlo esplicitamente.
