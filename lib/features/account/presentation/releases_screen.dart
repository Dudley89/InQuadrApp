import 'package:flutter/material.dart';

class ReleasesScreen extends StatelessWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        'v5: Riconoscimento con embeddings (da app esterna)',
        'Pipeline di matching locale su caratteristiche pre-calcolate.',
      ),
      (
        'v6: Mappa monumenti',
        'Navigazione visuale con punti di interesse e percorso rapido.',
      ),
      (
        'v7: Download pacchetti offline per area',
        'Contenuti e profili scaricabili per uso senza rete.',
      ),
      (
        'v8: Filtri accessibilità',
        'Preferenze per contrasto, testo grande e semplificazione contenuti.',
      ),
      (
        'v9: Profilo utente e preferenze',
        'Sincronizzazione locale delle impostazioni e storico visite.',
      ),
      (
        'v10: Suggestion intelligenti',
        'Suggerimenti monumenti vicini in base al contesto di utilizzo.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Prossime release')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            leading: const Icon(Icons.rocket_launch_outlined),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: items.length,
      ),
    );
  }
}
