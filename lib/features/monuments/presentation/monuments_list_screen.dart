import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../application/monuments_providers.dart';

class MonumentsListScreen extends ConsumerWidget {
  const MonumentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monuments = ref.watch(monumentsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monumenti')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: monuments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final monument = monuments[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_city_outlined),
              title: Text(monument.name),
              subtitle: Text(monument.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('${AppRoutePaths.monument}/${monument.id}'),
            ),
          );
        },
      ),
    );
  }
}
