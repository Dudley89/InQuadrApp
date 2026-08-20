import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../application/monuments_providers.dart';

class MonumentsListScreen extends ConsumerStatefulWidget {
  const MonumentsListScreen({super.key});

  @override
  ConsumerState<MonumentsListScreen> createState() => _MonumentsListScreenState();
}

class _MonumentsListScreenState extends ConsumerState<MonumentsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(monumentsRepositoryProvider);
    final monuments = repository.search(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Monumenti')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              hintText: 'Cerca monumento o località',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: monuments.isEmpty
                ? const Center(child: Text('Nessun monumento trovato.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: monuments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final monument = monuments[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_city_outlined),
                          title: Text(monument.name),
                          subtitle: Text(
                            monument.locality == null
                                ? monument.description
                                : '${monument.locality} · ${monument.address}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '${AppRoutePaths.monument}/${monument.id}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
