import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';

class MonumentDetailScreen extends StatelessWidget {
  const MonumentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheda Monumento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Colosseo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(
              child: Icon(Icons.account_balance, size: 64),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Anfiteatro simbolo di Roma, noto per la sua storia millenaria e la struttura iconica.',
          ),
          const SizedBox(height: 8),
          const ExpansionTile(
            title: Text('Approfondisci'),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('Contenuto di approfondimento placeholder per la V1.'),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Audio guida'),
                  Row(
                    children: [
                      IconButton(onPressed: null, icon: const Icon(Icons.play_arrow)),
                      IconButton(onPressed: null, icon: const Icon(Icons.pause)),
                      const Text('Controlli disponibili in V2'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Accessibilità'),
                  SizedBox(height: 8),
                  Text('• Testo grande'),
                  Text('• Trascrizione contenuti'),
                  Text('• Alto contrasto'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go(AppRoutePaths.camera),
            child: const Text('Torna alla fotocamera'),
          ),
        ],
      ),
    );
  }
}
