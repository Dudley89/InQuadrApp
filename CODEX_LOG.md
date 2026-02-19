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
- Definire naming definitivo del brand: `InQuadra` resta nome finale o solo provvisorio?
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
