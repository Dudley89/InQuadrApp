import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/router.dart';
import '../application/camera_permission_controller.dart';
import '../application/camera_preview_controller.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(cameraPermissionControllerProvider);
    final permissionController = ref.read(cameraPermissionControllerProvider.notifier);

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
          ElevatedButton(
            onPressed: permissionStatus == PermissionStatus.granted
                ? () => context.go(AppRoutePaths.monument)
                : null,
            child: const Text('Simula riconoscimento'),
          ),
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
      return const Text('Anteprima live pronta.');
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
            onPressed: () {
              onOpenSettingsPressed();
            },
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
