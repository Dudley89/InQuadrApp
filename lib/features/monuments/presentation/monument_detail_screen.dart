import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../application/monuments_providers.dart';

class MonumentDetailScreen extends ConsumerWidget {
  const MonumentDetailScreen({super.key, required this.monumentId});

  final String monumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monument = ref.watch(monumentByIdProvider(monumentId));

    if (monument == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scheda Monumento')),
        body: const Center(child: Text('Monumento non trovato.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scheda Monumento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(monument.name, style: Theme.of(context).textTheme.headlineSmall),
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
          Text(monument.description),
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Approfondisci'),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(monument.deepDive),
              ),
            ],
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Audio guida'),
                  Row(
                    children: [
                      IconButton(onPressed: null, icon: Icon(Icons.play_arrow)),
                      IconButton(onPressed: null, icon: Icon(Icons.pause)),
                      Text('Controlli disponibili in V4'),
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
                children: [
                  const Text('Accessibilità'),
                  const SizedBox(height: 8),
                  for (final item in monument.accessibility) Text('• $item'),
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
