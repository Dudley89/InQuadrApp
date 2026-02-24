import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/router.dart';
import '../../monuments/application/monuments_providers.dart';
import '../application/camera_permission_controller.dart';
import '../application/camera_preview_controller.dart';
import '../scan/scan_providers.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _didInitialSync = false;

  @override
  void dispose() {
    ref.read(scanControllerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = ref.watch(cameraPermissionControllerProvider);
    final permissionController = ref.read(cameraPermissionControllerProvider.notifier);

    ref.listen<PermissionStatus>(
      cameraPermissionControllerProvider,
      (previous, next) {
        if (next != PermissionStatus.granted) {
          ref.read(scanControllerProvider.notifier).stop();
          return;
        }

        final preview = ref.read(cameraPreviewControllerProvider);
        preview.whenData((controller) {
          ref.read(scanControllerProvider.notifier).start(controller);
        });
      },
    );

    ref.listen<AsyncValue<CameraController>>(
      cameraPreviewControllerProvider,
      (previous, next) {
        next.when(
          data: (controller) {
            final permission = ref.read(cameraPermissionControllerProvider);
            if (permission == PermissionStatus.granted) {
              ref.read(scanControllerProvider.notifier).start(controller);
            }
          },
          loading: () {},
          error: (_, __) {
            ref.read(scanControllerProvider.notifier).stop();
          },
        );
      },
    );

    if (!_didInitialSync) {
      _didInitialSync = true;
      Future.microtask(() {
        if (!mounted) {
          return;
        }

        final permission = ref.read(cameraPermissionControllerProvider);
        final preview = ref.read(cameraPreviewControllerProvider);

        if (permission != PermissionStatus.granted) {
          ref.read(scanControllerProvider.notifier).stop();
          return;
        }

        preview.whenData((controller) {
          ref.read(scanControllerProvider.notifier).start(controller);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fotocamera')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PreviewSection(permissionStatus: permissionStatus),
          const SizedBox(height: 16),
          _PermissionSection(
            status: permissionStatus,
            onGrantPressed: permissionController.requestPermission,
            onOpenSettingsPressed: openAppSettings,
          ),
          const SizedBox(height: 16),
          const _ScanStatusSection(),
        ],
      ),
    );
  }
}

class _PreviewSection extends ConsumerWidget {
  const _PreviewSection({required this.permissionStatus});

  final PermissionStatus permissionStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (permissionStatus != PermissionStatus.granted) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Center(
          child: Icon(Icons.camera_alt_outlined, size: 64),
        ),
      );
    }

    final cameraAsync = ref.watch(cameraPreviewControllerProvider);
    return cameraAsync.when(
      data: (controller) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
      loading: () => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Preview non disponibile: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionSection extends StatelessWidget {
  const _PermissionSection({
    required this.status,
    required this.onGrantPressed,
    required this.onOpenSettingsPressed,
  });

  final PermissionStatus status;
  final VoidCallback onGrantPressed;
  final Future<bool> Function() onOpenSettingsPressed;

  @override
  Widget build(BuildContext context) {
    if (status == PermissionStatus.granted) {
      return const Text('Anteprima live pronta. Scansione automatica attiva.');
    }

    if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permesso fotocamera bloccato. Apri le impostazioni di sistema per abilitarlo.',
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onOpenSettingsPressed,
            child: const Text('Apri impostazioni'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Per usare la fotocamera devi concedere il permesso.'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onGrantPressed,
          child: const Text('Concedi permesso'),
        ),
      ],
    );
  }
}

class _ScanStatusSection extends ConsumerWidget {
  const _ScanStatusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(cameraPermissionControllerProvider);
    final scanState = ref.watch(scanControllerProvider);

    if (permissionStatus != PermissionStatus.granted) {
      return const Text('Scansione disponibile dopo il permesso fotocamera.');
    }

    if (!scanState.isLocked) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (scanState.isBusy) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(scanState.message)),
            ],
          ),
        ),
      );
    }

    final lockedId = scanState.lockedMonumentId;
    if (lockedId == null) {
      return const SizedBox.shrink();
    }

    final monument = ref.watch(monumentByIdProvider(lockedId));
    if (monument == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monumento riconosciuto'),
              const SizedBox(height: 8),
              Text('ID: $lockedId'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.read(scanControllerProvider.notifier).retry(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monument.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(monument.description),
            const SizedBox(height: 8),
            Text('Confidenza: ${(scanState.lockedConfidence * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => context.push('${AppRoutePaths.monument}/$lockedId'),
                  child: const Text('Apri dettagli'),
                ),
                OutlinedButton(
                  onPressed: () => ref.read(scanControllerProvider.notifier).retry(),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
