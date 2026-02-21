import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/router.dart';
import '../application/monuments_providers.dart';
import '../domain/monument.dart';

class MonumentDetailScreen extends ConsumerStatefulWidget {
  const MonumentDetailScreen({super.key, required this.monumentId});

  final String monumentId;

  @override
  ConsumerState<MonumentDetailScreen> createState() => _MonumentDetailScreenState();
}

class _MonumentDetailScreenState extends ConsumerState<MonumentDetailScreen> {
  Monument? _selectedMarker;

  @override
  Widget build(BuildContext context) {
    final monument = ref.watch(monumentByIdProvider(widget.monumentId));

    if (monument == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scheda Monumento')),
        body: const Center(child: Text('Monumento non trovato.')),
      );
    }

    final allMonuments = ref.watch(monumentsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scheda Monumento')),
      body: FutureBuilder<Position?>(
        future: _resolveUserPosition(),
        builder: (context, snapshot) {
          final userPosition = snapshot.data;
          final nearbyMonuments = _nearbyMonuments(monument, allMonuments, 200);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(monument.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    monument.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('ID globale: ${monument.idGlobal}'),
              const SizedBox(height: 6),
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
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(monument.latitude, monument.longitude),
                      initialZoom: 16,
                      onTap: (_, __) => setState(() => _selectedMarker = null),
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
                              width: 48,
                              height: 48,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedMarker = item),
                                child: Icon(
                                  Icons.location_on,
                                  color: item.id == monument.id ? Colors.red : Colors.blue,
                                  size: item.id == monument.id ? 36 : 30,
                                ),
                              ),
                            ),
                          if (userPosition != null)
                            Marker(
                              point: LatLng(userPosition.latitude, userPosition.longitude),
                              width: 42,
                              height: 42,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La mappa usa strade OpenStreetMap. Raggio vicinanza impostato a 200m (da calibrare dopo test sul campo).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_selectedMarker != null) ...[
                const SizedBox(height: 8),
                _MarkerInfoCard(
                  marker: _selectedMarker!,
                  userPosition: userPosition,
                ),
              ],
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monumenti vicini (<= 200m)'),
                      const SizedBox(height: 6),
                      if (nearbyMonuments.isEmpty)
                        const Text('Nessun monumento vicino disponibile nel raggio impostato.'),
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
          );
        },
      ),
    );
  }

  Future<Position?> _resolveUserPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  List<Monument> _nearbyMonuments(
    Monument current,
    List<Monument> monuments,
    double maxMeters,
  ) {
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
      return meters <= maxMeters;
    }).toList();
  }
}

class _MarkerInfoCard extends StatelessWidget {
  const _MarkerInfoCard({required this.marker, required this.userPosition});

  final Monument marker;
  final Position? userPosition;

  @override
  Widget build(BuildContext context) {
    final distanceText = _distanceFromUser(marker, userPosition);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(marker.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(distanceText),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.push('${AppRoutePaths.monument}/${marker.id}'),
              child: const Text('Apri scheda monumento'),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceFromUser(Monument monument, Position? userPosition) {
    if (userPosition == null) {
      return 'Distanza utente non disponibile (permesso posizione non concesso).';
    }

    const distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      LatLng(userPosition.latitude, userPosition.longitude),
      LatLng(monument.latitude, monument.longitude),
    );

    return 'Distanza da te: ${meters.toStringAsFixed(0)} m';
  }
}
