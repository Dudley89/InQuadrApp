# REQUIREMENTS.md — InQuadra

Baseline dei requisiti. Sostituisce ogni specifica precedente ricostruita a memoria.

> **Attenzione — da verificare al primo utilizzo.**
> Gli stati marcati ✅ derivano dalla lettura di `CODEX_LOG.md` e del `README.md`, **non da una verifica sul codice compilato**. Molte iterazioni del log sono state chiuse senza mai eseguire `flutter analyze`. Prima di usare questo file come baseline, **rileggere il codice reale e correggere gli stati sbagliati**, poi rimuovere questo avviso.

Legenda: ✅ fatto · 🔧 da fare (MVP) · ⏸️ rimandato post-MVP · ❓ decisione aperta

---

## 1. Identità del prodotto

InQuadra è un'app turistica mobile: il visitatore inquadra un monumento con la fotocamera e l'app lo riconosce automaticamente, aprendo la scheda informativa.

- **Pilota:** Tagliacozzo (3 monumenti)
- **Architettura:** predisposta multi-Comune — Tagliacozzo è il primo dataset, non l'app stessa
- **Principio fondante:** niente QR code, niente scatto manuale, niente selezione preventiva del monumento da una lista

---

## 2. Riconoscimento — il cuore dell'app

**Pipeline:**

```
frame camera → image embedding → cosine similarity
   con i candidati → threshold → streak di conferme → lock
```

Il GPS **non riconosce** il monumento: prefiltra soltanto i candidati. È la computer vision a decidere.
Un LLM **non fa parte** della pipeline di riconoscimento: eventualmente serve solo per contenuti e narrazione.

| Requisito | Stato |
|---|---|
| Interfaccia `MonumentRecognizer` + `ScanController` (throttle, busy gating, streak, lock, retry) | ✅ |
| `MockMonumentRecognizer` con esito casuale | ✅ da **sostituire** |
| Modello di embedding on-device scelto e integrato | 🔧 |
| Embedding di riferimento generati per i 3 monumenti | 🔧 |
| Cosine similarity contro i candidati | 🔧 |
| Prefiltro geografico dei candidati | 🔧 |
| Scan automatico all'ingresso in camera, senza pulsante "Scatta" | ✅ |
| Stop dello scan all'uscita dalla schermata | ✅ |
| Feedback visivo + vibrazione al riconoscimento | ✅ |
| Card di conferma (`Apri dettagli` / `Riprova`), niente navigazione automatica | ✅ |
| Le foto di confronto non vengono conservate su disco | ✅ |

### Parametri

| Parametro | Nel codice | Nella spec | Nota |
|---|---|---|---|
| Threshold | 0.75 | 0.88 | ⚠️ **Da misurare, non da decidere.** La soglia dipende dal modello scelto. Prima di fissarla, calcolare la distribuzione delle similarità: stesso monumento (angoli/luce/ora diversi) vs monumenti diversi. La soglia va nel punto di separazione osservato. 0.88 su un embedding generalista è probabilmente troppo alto e rischia di non riconoscere mai nulla. |
| Conferme consecutive | 3 | 3 | ✅ allineato |
| Intervallo di scansione | 600 ms | 1 s | 🔧 portare a 1 s (più margine per l'inferenza on-device) |
| Raggio prefiltro GPS | — | 50 m | ⚠️ **50 m è rischioso.** L'errore GPS in centro storico è spesso 15–30 m, e un monumento lo si inquadra anche da 80–100 m. Con 50 m il candidato corretto può sparire dal set. Baseline consigliata: **200–250 m**, oppure `accuratezza_GPS + 150 m`. Con soli 3 monumenti il prefiltro è comunque ininfluente sull'MVP: implementarlo con la forma giusta, tararlo dopo. |

---

## 3. Navigazione e schermate

| Requisito | Stato |
|---|---|
| Avvio diretto su Home, senza gate iniziale | ✅ (route `/startup` rimossa di proposito) |
| Permessi richiesti solo quando servono (camera in Fotocamera, posizione in Esplora) | ✅ |
| Bottom navigation | ⚠️ nel codice **4 voci** (Home / Scansiona / Monumenti / Impostazioni), la spec ne chiede **3** (Esplora / Fotocamera / Impostazioni) → ⏸️ **rimandato**: refactor cosmetico, non tocca il valore dell'app |
| Home con mappa OSM, posizione utente, monumenti vicini ordinati per distanza | ✅ |
| Raggio "monumenti vicini" in UI: 200 m (concetto distinto dal prefiltro riconoscimento) | ✅ |
| CTA visibile per avviare il riconoscimento | ✅ |
| Scheda monumento: nome, immagine, descrizione, approfondimento, accessibilità, mappa | ✅ |
| Selezione della località / concetto di "luogo attivo" | ⏸️ **rimandato** — vedi §5 |
| Schermata Impostazioni con switch riconoscimento automatico | ✅ |
| Route `/releases` (elenco prossime release) | ✅ non prevista dalla spec, ma innocua: tenere |

---

## 4. Modello dati

Modello definitivo — il "nucleo minimo" della spec **più** i campi già implementati e usati in UI:

```dart
Monument
 ├─ id
 ├─ idGlobal          // mantenuto: chiave per il futuro backend
 ├─ name
 ├─ description
 ├─ deepDive          // mantenuto: usato nella scheda
 ├─ accessibility     // mantenuto: requisito dichiarato del prodotto
 ├─ latitude
 ├─ longitude
 └─ images[]          // 🔧 migrazione da imageUrl (singolo) a lista
```

❓ **Decisione presa:** `idGlobal`, `deepDive` e `accessibility` **restano**. Sono implementati, usati, e l'accessibilità è un pilastro dichiarato del prodotto. Il "modello minimo" della spec ricostruita non li elimina: li ometteva soltanto.

🔧 **Da fare:** `imageUrl` → `images[]`. Un monumento ha bisogno di più immagini di riferimento per il riconoscimento (angoli, luce, stagioni diverse).

Dataset pilota: Obelisco (`1001`), Chiostro di San Francesco (`1002`), Statua di Dante (`1003`).

---

## 5. Multi-Comune

**Obiettivo architetturale:** InQuadra è una piattaforma, non "l'app di Tagliacozzo".

Per l'MVP:

- 🔧 il dataset va strutturato **per località** (un file/asset per Comune), con il repository che ne carica uno;
- ⏸️ la **schermata di selezione della località** è rimandata: con un solo Comune non serve, e costa giorni che servono al riconoscimento.

Rimandati esplicitamente post-MVP: backend/Firebase, storage remoto, CMS contenuti, account utente, analytics, AR.

---

## 6. Contenuti e offline

- ✅ Dataset locale statico: l'app funziona senza connessione continua
- ✅ Caching immagini su disco (`cached_network_image`)
- ✅ Badge stato rete non bloccante
- Contenuti curati per il luogo, non copiati da Wikipedia

---

## 7. Stack tecnico

```
Flutter / Dart
Riverpod 2.6.1        state management
go_router             navigazione
camera                preview + frame
geolocator            posizione
flutter_map + OSM     mappa
permission_handler    permessi
connectivity_plus     stato rete
```

Android: AGP 8.6.0, Gradle 8.7.
Versioni Flutter/Dart: **da rileggere dal progetto reale**, non dai valori riportati nelle vecchie iterazioni.

⚠️ Verificare lo stato delle dipendenze rispetto al manifest e al lockfile correnti.

---

## 8. Definizione di "MVP consegnabile"

L'MVP è raggiunto quando, su device Android reale, a Tagliacozzo:

1. l'app parte, la Home mostra mappa e monumenti vicini;
2. si apre la Fotocamera e lo scan parte da solo;
3. inquadrando l'Obelisco, l'app lo riconosce entro pochi secondi con vibrazione e card;
4. `Apri dettagli` porta alla scheda giusta;
5. lo stesso vale per Chiostro e Statua di Dante;
6. inquadrando qualcos'altro, l'app **non** riconosce nulla (nessun falso positivo evidente);
7. `flutter analyze` è pulito e `flutter test` è verde.

Tutto ciò che non serve a questi sette punti è fuori dallo scope della settimana.
