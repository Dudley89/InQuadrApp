# CLAUDE.md — InQuadra

Istruzioni operative per Claude Code su questo repository.
Leggere **sempre** questo file e `REQUIREMENTS.md` prima di iniziare qualsiasi iterazione.

---

## 1. Contesto ambiente

- **OS sviluppo:** Windows
- **Target:** Android (device fisico collegato via USB). **iOS non è compilabile** su questa macchina: non modificare `ios/` se non richiesto esplicitamente, e non proporre fix iOS come parte di un'iterazione.
- **Flusso di lavoro dell'utente:**
  - Terminale A: `flutter run` sul device reale, lasciato aperto, hot reload con `r`.
  - Terminale B: Claude Code.

---

## 2. Regola non negoziabile: nessuna iterazione chiusa senza verifica

Prima di dichiarare completata **qualsiasi** modifica, in quest'ordine:

```
flutter analyze      # deve terminare senza issue
flutter test         # deve essere verde
```

Se uno dei due fallisce, **non** riportare il task come completato: correggi e ripeti.

Se non riesci a far passare `analyze` o `test` dopo due tentativi, **fermati e spiega il problema** invece di continuare a modificare file.

Il commit avviene solo dopo che entrambi passano.

### Errori runtime

Per un crash o un comportamento anomalo sul device, non chiedere all'utente di descrivere l'errore. Leggilo:

```
adb logcat -c                    # pulisci il buffer PRIMA di riprodurre
# (l'utente riproduce il bug)
adb logcat -d                    # scarica il buffer ed esce
adb logcat -d -s flutter         # solo i log Flutter, se il rumore è troppo
```

Non usare `flutter run | tee` né altre redirezioni dello stdout: rompono l'hot reload interattivo su Windows.

---

## 3. Storico del progetto: `CODEX_LOG.md`

`CODEX_LOG.md` in root è il diario del progetto. Va:

- **letto all'inizio** di ogni sessione (almeno le ultime 3 iterazioni);
- **aggiornato alla fine** di ogni iterazione con: cosa è stato fatto, problemi rilevati, decisioni prese, prossimi passi.

Attenzione: il log contiene decine di iterazioni chiuse con la nota *"SDK Flutter assente, validazione non eseguita"*. Quelle modifiche **non sono mai state verificate**. Non dare per scontato che il codice descritto in quelle voci compili o funzioni.

---

## 4. Stato di partenza da verificare

Prima di scrivere codice nuovo, va sanata la toolchain. In `pubspec.yaml` risulta un bump major di quasi tutte le dipendenze (permission_handler 12, connectivity_plus 7, geolocator 14, camera 0.12, flutter_map 8.2.2, go_router 17.1) seguito da un pin di `flutter_riverpod` a **2.6.1** con `dependency_overrides`, **senza che `flutter pub get` sia mai stato eseguito**.

Primo task assoluto:

```
flutter pub get
flutter analyze
flutter test
flutter run
```

Finché questi quattro comandi non passano, **nessuna feature nuova**.

---

## 5. Vincoli tecnici

- **State management:** Riverpod **2.x** (API `StateNotifierProvider` / `StateProvider` / `StateNotifier`). Non migrare a Riverpod 3 senza richiesta esplicita.
- **Routing:** `go_router`. Le route principali sono wrappate in `AppShell`.
- **Mappa:** `flutter_map` + OpenStreetMap. **Non** introdurre Google Maps.
- **Nessuna nuova dipendenza** in `pubspec.yaml` senza aver prima chiesto e ottenuto conferma, spiegando perché non basta quello che c'è.
- **Nessun downgrade/upgrade di dipendenze** come effetto collaterale di un altro task.
- Ogni modifica a `pubspec.yaml` è seguita immediatamente da `flutter pub get` + `flutter analyze`.

---

## 6. Architettura da rispettare

```
lib/app/         bootstrap, router, tema, AppShell
lib/features/    camera/, monuments/  (una cartella per feature)
lib/shared/      logger, widget condivisi
```

Non spostare codice tra questi livelli senza motivo. Non creare cartelle nuove a questo livello senza chiedere.

L'interfaccia `MonumentRecognizer` è il punto di estensione del riconoscimento: implementazioni nuove si aggiungono dietro quell'interfaccia, **senza modificare `ScanController`** (throttling, busy gating, streak, lock sono logica già validata e non va riscritta).

---

## 7. Cosa NON toccare senza richiesta esplicita

Queste parti sono già implementate e funzionanti. Non "migliorarle" di iniziativa:

- Avvio diretto su `/home` e permessi richiesti on-demand (lo startup gate è stato **rimosso** di proposito).
- Stop/restart dello scan legato al ciclo di vita della route (`RouteAware`, `didPushNext` / `didPopNext`).
- Card di conferma dopo il riconoscimento con `Apri dettagli` / `Riprova`. **Non** navigare automaticamente alla scheda.
- Cancellazione dei file temporanei di `takePicture()` nel blocco `finally`.
- Feedback aptico al lock.
- Campi `idGlobal`, `deepDive`, `accessibility` del modello `Monument`: **restano**.

---

## 8. Stile di lavoro

- **Un task alla volta.** Non accorpare più obiettivi in un'unica iterazione.
- Per lavori architetturali o decisioni non banali: usa **plan mode**, presenta il piano e aspetta approvazione prima di scrivere.
- Modifiche minime e mirate. Non riformattare file che non c'entrano con il task.
- **Un commit git per iterazione**, con messaggio che descrive cosa cambia e perché.
- Se una richiesta contraddice questo file o `REQUIREMENTS.md`, **segnalalo** invece di eseguire in silenzio.

---

## 9. Comandi frequenti

```
flutter pub get
flutter analyze
flutter test
flutter test test/percorso_specifico_test.dart
flutter devices
adb devices
adb logcat -d -s flutter
flutter clean            # solo se necessario, è lento
```
