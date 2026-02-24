import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/monuments/application/monuments_providers.dart';
import '../../features/monuments/domain/monument.dart';

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
    final nearbyItems = monuments.take(6).toList();
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
                  trailing: TextButton(
                    onPressed: () {},
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
                        onTap: () =>
                            context.push('${AppRoutePaths.monument}/${monument.id}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle(title: 'In evidenza'),
                const SizedBox(height: 8),
                _FeaturedCard(
                  monument: featured,
                  onTap: () => context.push('${AppRoutePaths.monument}/${featured.id}'),
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
                      onTap: () =>
                          context.push('${AppRoutePaths.monument}/${monument.id}'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Come funziona: inquadra un monumento, attendi il riconoscimento automatico e apri la scheda dettagliata.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.greeting, required this.onOpenReleases});

  final String greeting;
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
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.photo_outlined, size: 54),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
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
                FilledButton(
                  onPressed: onOpenCamera,
                  child: const Text('Apri fotocamera'),
                ),
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
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
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
                  child: Image.network(
                    monument.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.photo_outlined),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  monument.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.monument, required this.onTap});

  final Monument monument;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                monument.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.photo_outlined, size: 54),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      monument.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: onTap,
                    child: const Text('Scopri'),
                  ),
                ],
              ),
            ),
          ],
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
                    child: Image.network(
                      monument.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.photo_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                monument.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
