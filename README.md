# InQuadra (V3)

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
- startup gate bloccante: controllo internet + servizio posizione + permessi posizione/camera, dialog con apertura impostazioni e ricontrollo al resume
- `lib/features/monuments`: dataset locale, repository e schermate lista/dettaglio
- `lib/shared`: utility logger e widget condivisi

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
