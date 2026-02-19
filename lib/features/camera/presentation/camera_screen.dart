import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/router.dart';
import '../application/camera_permission_controller.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(cameraPermissionControllerProvider);
    final controller = ref.read(cameraPermissionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Fotocamera')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined, size: 64),
            ),
          ),
          const SizedBox(height: 16),
          if (permissionStatus != PermissionStatus.granted) ...[
            const Text(
              'Per usare la fotocamera devi concedere il permesso.',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.requestPermission,
              child: const Text('Concedi permesso'),
            ),
          ] else ...[
            const Text('Preview pronta (placeholder).'),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutePaths.monument),
            child: const Text('Simula riconoscimento'),
          ),
        ],
      ),
    );
  }
}
