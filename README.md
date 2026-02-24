# InQuadra (V3.x)

Versione V3 Flutter dell'app InQuadra: include architettura modulare, navigazione, tema coerente, camera live preview con permessi, contenuti monumenti **locali/offline** e mappa stradale con posizione utente + monumenti vicini nella scheda dettaglio.

## Requisiti

- Flutter stable con Dart 3+
- Android Studio/Xcode per target Android e iOS

## Avvio

```bash
flutter pub get
flutter run
```

## Struttura progetto

- `lib/app`: bootstrap, router, tema
- `lib/features/camera`: permessi camera + preview live (`camera`)

- fotocamera: scanning automatico throttled (600ms), lock dopo 3 riconoscimenti stabili sopra soglia, azioni Apri dettagli / Riprova
- startup gate bloccante: controllo internet + servizio posizione + permessi posizione/camera, dialog con apertura impostazioni e ricontrollo al resume
- `lib/features/monuments`: dataset locale, repository e schermate lista/dettaglio
- `lib/shared`: utility logger e widget condivisi



## Startup requirements gate

All'avvio l'app apre la route `/startup` e verifica requisiti obbligatori prima di permettere l'uso delle feature:
- internet attivo (Wi-Fi o dati mobili),
- servizi posizione (GPS) attivi,
- permesso posizione concesso,
- permesso fotocamera concesso.

Se manca qualcosa, viene mostrata una schermata dedicata con stato dei requisiti, azioni mirate (richiesta permesso / apertura impostazioni) e pulsante `Retry`.
La navigazione verso `/home` avviene solo quando tutti i requisiti sono soddisfatti.

## Test

```bash
flutter test
```

## Versioni progetto

Le versioni applicative e di toolchain sono tracciate in root in `VERSION_MATRIX.md`.

## Roadmap breve

- **V4**: riconoscimento monumenti e backend
- **V5**: miglioramenti accessibilità avanzati e audio guida reale

## Continuità sviluppo: `CODEX_LOG.md`

Il file in root `CODEX_LOG.md` è la fonte di verità del progetto.
Va **sempre letto prima di iniziare** ogni iterazione e **aggiornato a fine iterazione** con:

- domande aperte
- problemi rilevati
- decisioni prese
- cosa è stato fatto
- prossimi passi
