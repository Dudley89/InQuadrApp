import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/location/application/location_controller.dart';
import '../../features/monuments/application/monuments_providers.dart';
import '../../features/monuments/domain/monument.dart';
import '../../features/settings/application/settings_providers.dart';
import '../network/network_status_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Sei sicuro di uscire?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sì'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour <= 11) {
      return 'Buongiorno!';
    }
    if (hour >= 12 && hour <= 17) {
      return 'Buon pomeriggio!';
    }
    return 'Buona sera!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monuments = ref.watch(monumentsListProvider);
    final featured = ref.watch(featuredMonumentProvider);
    final locationState = ref.watch(locationControllerProvider);
    final tipsVisible = ref.watch(tipsVisibleProvider);
    final networkStatus = ref.watch(networkStatusProvider);

    final nearbyItems = _sortedNearby(monuments, locationState).take(6).toList();
    final gridItems = monuments.take(6).toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(
                  greeting: _greeting(DateTime.now()),
                  networkStatus: networkStatus,
                  onOpenReleases: () => context.push(AppRoutePaths.releases),
                ),
                const SizedBox(height: 18),
                _HeroScanCard(
                  imageUrl: featured.imageUrl,
                  onOpenCamera: () => context.push(AppRoutePaths.camera),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Vicino a te',
                  trailing: locationState.enabled &&
                          locationState.latitude != null &&
                          locationState.longitude != null
                      ? null
                      : TextButton(
                          onPressed: () => ref.read(locationControllerProvider.notifier).enable(),
                          child: const Text('Attiva posizione'),
                        ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearbyItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final monument = nearbyItems[index];
                      return _NearbyCard(
                        monument: monument,
                        onTap: () => context.push('${AppRoutePaths.monument}/${monument.id}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Tutti i monumenti',
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutePaths.monuments),
                    child: const Text('Vedi tutti'),
                  ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gridItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.16,
                  ),
                  itemBuilder: (context, index) {
                    final monument = gridItems[index];
                    return _MiniMonumentCard(
                      monument: monument,
                      onTap: () => context.push('${AppRoutePaths.monument}/${monument.id}'),
                    );
                  },
                ),
                if (tipsVisible) ...[
                  const SizedBox(height: 20),
                  _TipsCard(
                    onHide: () => ref.read(tipsVisibleProvider.notifier).state = false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Monument> _sortedNearby(List<Monument> monuments, LocationState locationState) {
    if (locationState.latitude == null || locationState.longitude == null) {
      return monuments;
    }

    final items = [...monuments];
    items.sort((a, b) {
      final da = _distanceKm(
        locationState.latitude!,
        locationState.longitude!,
        a.latitude,
        a.longitude,
      );
      final db = _distanceKm(
        locationState.latitude!,
        locationState.longitude!,
        b.latitude,
        b.longitude,
      );
      return da.compareTo(db);
    });
    return items;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double value) => value * math.pi / 180;
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.greeting,
    required this.networkStatus,
    required this.onOpenReleases,
  });

  final String greeting;
  final AsyncValue<NetworkStatus> networkStatus;
  final VoidCallback onOpenReleases;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Scansiona e scopri i monumenti intorno a te',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              _NetworkBadge(status: networkStatus),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onOpenReleases,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  const _NetworkBadge({required this.status});

  final AsyncValue<NetworkStatus> status;

  @override
  Widget build(BuildContext context) {
    return status.when(
      data: (value) => Chip(
        label: Text(value == NetworkStatus.online ? 'Online' : 'Offline'),
        avatar: Icon(
          value == NetworkStatus.online ? Icons.wifi : Icons.wifi_off,
          size: 18,
          color: value == NetworkStatus.online ? Colors.green : Colors.orange,
        ),
      ),
      loading: () => const Chip(label: Text('Rete...')),
      error: (_, __) => const Chip(label: Text('Rete sconosciuta')),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard({required this.imageUrl, required this.onOpenCamera});

  final String imageUrl;
  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.photo_outlined, size: 54),
              ),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inquadra un monumento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(onPressed: onOpenCamera, child: const Text('Apri fotocamera')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.monument, required this.onTap});

  final Monument monument;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: monument.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.photo_outlined),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(monument.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMonumentCard extends StatelessWidget {
  const _MiniMonumentCard({required this.monument, required this.onTap});

  final Monument monument;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: monument.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.photo_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(monument.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.onHide});

  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Suggerimenti', style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton(onPressed: onHide, child: const Text('Nascondi')),
              ],
            ),
            const SizedBox(height: 8),
            const _TipRow(icon: Icons.center_focus_strong, text: 'Centra il monumento nelle parentesi.'),
            const SizedBox(height: 8),
            const _TipRow(icon: Icons.zoom_in, text: 'Avvicinati per migliorare la stabilità del riconoscimento.'),
            const SizedBox(height: 8),
            const _TipRow(icon: Icons.wb_sunny_outlined, text: 'Con buona luce la confidenza aumenta sensibilmente.'),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
