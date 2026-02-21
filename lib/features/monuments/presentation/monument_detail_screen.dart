import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../application/monuments_providers.dart';
import '../domain/monument.dart';

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

    final allMonuments = ref.watch(monumentsListProvider);
    final nearbyMonuments = _nearbyMonuments(monument, allMonuments);

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
          const SizedBox(height: 8),
          Text('Mappa e monumenti vicini', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(monument.latitude, monument.longitude),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.inquadra',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final item in allMonuments)
                        Marker(
                          point: LatLng(item.latitude, item.longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: item.id == monument.id ? Colors.red : Colors.blue,
                            size: item.id == monument.id ? 34 : 28,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monumenti vicini'),
                  const SizedBox(height: 6),
                  if (nearbyMonuments.isEmpty)
                    const Text('Nessun monumento vicino disponibile.'),
                  for (final item in nearbyMonuments) Text('• ${item.name}'),
                ],
              ),
            ),
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
        ],
      ),
    );
  }

  List<Monument> _nearbyMonuments(Monument current, List<Monument> monuments) {
    const distance = Distance();
    return monuments.where((item) {
      if (item.id == current.id) {
        return false;
      }
      final meters = distance.as(
        LengthUnit.Meter,
        LatLng(current.latitude, current.longitude),
        LatLng(item.latitude, item.longitude),
      );
      return meters <= 1000;
    }).toList();
  }
}
