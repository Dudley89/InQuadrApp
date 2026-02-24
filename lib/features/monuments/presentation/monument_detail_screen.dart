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
  bool _showNextNearbyOverlay = false;
  Monument? _nextNearbyMonument;
  double? _nextNearbyDistanceMeters;
  bool _nextDistanceFromUser = false;

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
                height: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(monument.latitude, monument.longitude),
                          initialZoom: 16,
                          minZoom: 15.5,
                          maxZoom: 19,
                          onTap: (_, __) {
                            _onMapBackgroundTap(
                              currentMonument: monument,
                              allMonuments: allMonuments,
                              userPosition: userPosition,
                            );
                          },
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
                                    onTap: () => setState(() {
                                      _selectedMarker = item;
                                      _showNextNearbyOverlay = false;
                                    }),
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
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: _MarkerInfoCard(
                          selectedMonument: monument,
                          marker: _selectedMarker ?? monument,
                          isVisible: _selectedMarker != null,
                          onClose: () => setState(() => _selectedMarker = null),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: _NextNearbyOverlayCard(
                          isVisible: _showNextNearbyOverlay,
                          nearbyMonument: _nextNearbyMonument,
                          distanceMeters: _nextNearbyDistanceMeters,
                          distanceFromUser: _nextDistanceFromUser,
                          onClose: () => setState(() {
                            _showNextNearbyOverlay = false;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La mappa usa strade OpenStreetMap. Zoom out massimo limitato a circa 1km di raggio. Raggio vicinanza impostato a 200m (da calibrare dopo test sul campo).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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

  void _onMapBackgroundTap({
    required Monument currentMonument,
    required List<Monument> allMonuments,
    required Position? userPosition,
  }) {
    final nearby = _nearbyMonuments(currentMonument, allMonuments, 200);

    if (nearby.isEmpty) {
      setState(() {
        _selectedMarker = null;
        _nextNearbyMonument = null;
        _nextNearbyDistanceMeters = null;
        _nextDistanceFromUser = userPosition != null;
        _showNextNearbyOverlay = true;
      });
      return;
    }

    final origin = userPosition != null
        ? LatLng(userPosition.latitude, userPosition.longitude)
        : LatLng(currentMonument.latitude, currentMonument.longitude);

    final next = _closestFromOrigin(origin, nearby);
    final meters = _distanceMeters(
      origin,
      LatLng(next.latitude, next.longitude),
    );

    setState(() {
      _selectedMarker = null;
      _nextNearbyMonument = next;
      _nextNearbyDistanceMeters = meters;
      _nextDistanceFromUser = userPosition != null;
      _showNextNearbyOverlay = true;
    });
  }

  Monument _closestFromOrigin(LatLng origin, List<Monument> monuments) {
    final sorted = [...monuments]
      ..sort((a, b) {
        final distanceA = _distanceMeters(origin, LatLng(a.latitude, a.longitude));
        final distanceB = _distanceMeters(origin, LatLng(b.latitude, b.longitude));
        return distanceA.compareTo(distanceB);
      });
    return sorted.first;
  }

  double _distanceMeters(LatLng from, LatLng to) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, from, to);
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
    return monuments.where((item) {
      if (item.id == current.id) {
        return false;
      }
      final meters = _distanceMeters(
        LatLng(current.latitude, current.longitude),
        LatLng(item.latitude, item.longitude),
      );
      return meters <= maxMeters;
    }).toList();
  }
}

class _MarkerInfoCard extends StatelessWidget {
  const _MarkerInfoCard({
    required this.selectedMonument,
    required this.marker,
    required this.isVisible,
    required this.onClose,
  });

  final Monument selectedMonument;
  final Monument marker;
  final bool isVisible;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final distanceText = _distanceFromSelected(selectedMonument, marker);

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          marker.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Chiudi',
                      ),
                    ],
                  ),
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
          ),
        ),
      ),
    );
  }

  String _distanceFromSelected(Monument selected, Monument tapped) {
    const distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      LatLng(selected.latitude, selected.longitude),
      LatLng(tapped.latitude, tapped.longitude),
    );

    return 'Distanza: ${meters.toStringAsFixed(0)} m';
  }
}

class _NextNearbyOverlayCard extends StatelessWidget {
  const _NextNearbyOverlayCard({
    required this.isVisible,
    required this.nearbyMonument,
    required this.distanceMeters,
    required this.distanceFromUser,
    required this.onClose,
  });

  final bool isVisible;
  final Monument? nearbyMonument;
  final double? distanceMeters;
  final bool distanceFromUser;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prossimo punto vicino',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Chiudi',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (nearbyMonument == null) ...[
                    const Text('Nessun punto vicino entro 200m.'),
                  ] else ...[
                    Text(
                      nearbyMonument!.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    if (distanceMeters != null)
                      Text('Distanza: ${distanceMeters!.round()} m'),
                    if (!distanceFromUser)
                      Text(
                        'Posizione non disponibile: distanza calcolata dal monumento corrente.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Tocca un marker per dettagli.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
