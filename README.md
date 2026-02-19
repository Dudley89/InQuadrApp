# InQuadra (V1)

Versione iniziale Flutter dell'app InQuadra: include architettura base, navigazione, tema, placeholder UI e gestione permessi fotocamera (solo richiesta/stato).

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
- `lib/features/camera`: placeholder camera e permessi
- `lib/features/monuments`: scheda monumento placeholder
- `lib/shared`: utility logger e widget condivisi

## Test

```bash
flutter test
```

## Roadmap breve

- **V2**: integrazione camera live (preview reale)
- **V3**: contenuti monumenti locali/offline
- **V4**: riconoscimento monumenti e backend

## Continuità sviluppo: `CODEX_LOG.md`

Il file in root `CODEX_LOG.md` è la fonte di verità del progetto.
Va **sempre letto prima di iniziare** ogni iterazione e **aggiornato a fine iterazione** con:

- domande aperte
- problemi rilevati
- decisioni prese
- cosa è stato fatto
- prossimi passi
