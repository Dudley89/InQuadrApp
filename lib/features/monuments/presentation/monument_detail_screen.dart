import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/router.dart';
import '../../location/application/location_controller.dart';
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
    final nearbyMonuments = _nearbyMonuments(monument, allMonuments, 200);
    final locationState = ref.watch(locationControllerProvider);
    final LatLng? userLatLng =
        (locationState.enabled &&
            locationState.latitude != null &&
            locationState.longitude != null)
        ? LatLng(locationState.latitude!, locationState.longitude!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Scheda Monumento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(monument.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _openMapSheet(monument, allMonuments, userLatLng),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Mappa'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _openAudioGuideSheet(monument),
                  icon: const Icon(Icons.headphones_outlined),
                  label: const Text('Audio guida'),
                ),
              ),
            ],
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
              borderRadius: BorderRadius.circular(16),
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
                          userLatLng: userLatLng,
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
                          ..._buildMonumentMarkers(
                            allMonuments: allMonuments,
                            currentMonument: monument,
                            onTap: (item) => setState(() {
                              _selectedMarker = item;
                              _showNextNearbyOverlay = false;
                            }),
                          ),
                          if (userLatLng != null) _buildUserMarker(userLatLng),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accessibilità'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in monument.accessibility)
                        Chip(label: Text(item)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMapSheet(
    Monument currentMonument,
    List<Monument> allMonuments,
    LatLng? userLatLng,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullMapSheet(
        currentMonument: currentMonument,
        allMonuments: allMonuments,
        userLatLng: userLatLng,
      ),
    );
  }

  void _openAudioGuideSheet(Monument monument) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AudioGuideSheet(monumentName: monument.name),
    );
  }

  void _onMapBackgroundTap({
    required Monument currentMonument,
    required List<Monument> allMonuments,
    required LatLng? userLatLng,
  }) {
    final nearby = _nearbyMonuments(currentMonument, allMonuments, 200);

    if (nearby.isEmpty) {
      setState(() {
        _selectedMarker = null;
        _nextNearbyMonument = null;
        _nextNearbyDistanceMeters = null;
        _nextDistanceFromUser = userLatLng != null;
        _showNextNearbyOverlay = true;
      });
      return;
    }

    final origin = userLatLng ?? LatLng(currentMonument.latitude, currentMonument.longitude);

    final next = _closestFromOrigin(origin, nearby);
    final meters = _distanceMeters(
      origin,
      LatLng(next.latitude, next.longitude),
    );

    setState(() {
      _selectedMarker = null;
      _nextNearbyMonument = next;
      _nextNearbyDistanceMeters = meters;
      _nextDistanceFromUser = userLatLng != null;
      _showNextNearbyOverlay = true;
    });
  }

  List<Marker> _buildMonumentMarkers({
    required List<Monument> allMonuments,
    required Monument currentMonument,
    required ValueChanged<Monument> onTap,
  }) {
    return [
      for (final item in allMonuments)
        Marker(
          point: LatLng(item.latitude, item.longitude),
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => onTap(item),
            child: Icon(
              Icons.location_on,
              color: item.id == currentMonument.id ? Colors.red : Colors.blue,
              size: item.id == currentMonument.id ? 36 : 30,
            ),
          ),
        ),
    ];
  }

  Marker _buildUserMarker(LatLng userLatLng) {
    return Marker(
      point: userLatLng,
      width: 42,
      height: 42,
      child: const Icon(
        Icons.my_location,
        color: Colors.green,
        size: 28,
      ),
    );
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

class _FullMapSheet extends StatefulWidget {
  const _FullMapSheet({
    required this.currentMonument,
    required this.allMonuments,
    required this.userLatLng,
  });

  final Monument currentMonument;
  final List<Monument> allMonuments;
  final LatLng? userLatLng;

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

class _FullMapSheetState extends State<_FullMapSheet> {
  Monument? _selectedMarker;
  Monument? _nextNearbyMonument;
  double? _nextNearbyDistanceMeters;
  bool _showNextNearbyOverlay = false;
  bool _nextDistanceFromUser = false;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Container(
      margin: const EdgeInsets.all(12),
      height: maxHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Mappa', style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          widget.currentMonument.latitude,
                          widget.currentMonument.longitude,
                        ),
                        initialZoom: 16,
                        minZoom: 15.5,
                        maxZoom: 19,
                        onTap: (_, __) => _onMapBackgroundTap(),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.inquadra',
                        ),
                        MarkerLayer(
                          markers: [
                            ...[
                              for (final item in widget.allMonuments)
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
                                      color: item.id == widget.currentMonument.id
                                          ? Colors.red
                                          : Colors.blue,
                                      size: item.id == widget.currentMonument.id ? 36 : 30,
                                    ),
                                  ),
                                ),
                            ],
                            if (widget.userLatLng != null)
                              Marker(
                                point: widget.userLatLng!,
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
                        selectedMonument: widget.currentMonument,
                        marker: _selectedMarker ?? widget.currentMonument,
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
          ],
        ),
      ),
    );
  }

  void _onMapBackgroundTap() {
    final nearby = _nearbyMonuments(widget.currentMonument, widget.allMonuments, 200);

    if (nearby.isEmpty) {
      setState(() {
        _selectedMarker = null;
        _nextNearbyMonument = null;
        _nextNearbyDistanceMeters = null;
        _nextDistanceFromUser = widget.userLatLng != null;
        _showNextNearbyOverlay = true;
      });
      return;
    }

    final origin =
        widget.userLatLng ?? LatLng(widget.currentMonument.latitude, widget.currentMonument.longitude);

    final next = _closestFromOrigin(origin, nearby);
    final meters = _distanceMeters(origin, LatLng(next.latitude, next.longitude));

    setState(() {
      _selectedMarker = null;
      _nextNearbyMonument = next;
      _nextNearbyDistanceMeters = meters;
      _nextDistanceFromUser = widget.userLatLng != null;
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

class _AudioGuideSheet extends StatefulWidget {
  const _AudioGuideSheet({required this.monumentName});

  final String monumentName;

  @override
  State<_AudioGuideSheet> createState() => _AudioGuideSheetState();
}

class _AudioGuideSheetState extends State<_AudioGuideSheet> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Audio guida', style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.monumentName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          IconButton.filledTonal(
            onPressed: () => setState(() => _isPlaying = !_isPlaying),
            iconSize: 42,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(value: 0.35),
          const SizedBox(height: 10),
          Text(
            'Disponibile prossimamente',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ),
        ],
      ),
    );
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
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.network(
                        marker.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                marker.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close),
                              tooltip: 'Chiudi',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distanceText,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => context.push('${AppRoutePaths.monument}/${marker.id}'),
                          child: const Text('Apri scheda'),
                        ),
                      ],
                    ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
