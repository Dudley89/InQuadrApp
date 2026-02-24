import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/router.dart';
import '../../monuments/application/monuments_providers.dart';
import '../../monuments/domain/monument.dart';
import '../../settings/application/settings_providers.dart';
import '../application/camera_permission_controller.dart';
import '../application/camera_preview_controller.dart';
import '../scan/scan_providers.dart';
import '../scan/scan_state.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with RouteAware, WidgetsBindingObserver {
  bool _didInitialSync = false;
  bool _routeSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubscribed) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didPushNext() {
    ref.read(scanControllerProvider.notifier).stop();
  }

  @override
  void didPopNext() {
    _syncScanStateFromCurrentConditions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(scanControllerProvider.notifier).stop();
      return;
    }

    if (state == AppLifecycleState.resumed && _isCurrentRoute()) {
      _syncScanStateFromCurrentConditions();
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    ref.read(scanControllerProvider.notifier).stop();
    super.dispose();
  }

  bool _isCurrentRoute() => ModalRoute.of(context)?.isCurrent ?? false;

  void _syncScanStateFromCurrentConditions() {
    if (!mounted || !_isCurrentRoute()) {
      return;
    }

    final scan = ref.read(scanControllerProvider.notifier);
    final autoRecognition = ref.read(autoRecognitionEnabledProvider);
    final permission = ref.read(cameraPermissionControllerProvider);
    final preview = ref.read(cameraPreviewControllerProvider);

    if (!autoRecognition || permission != PermissionStatus.granted) {
      scan.stop();
      return;
    }

    preview.whenData(scan.start);
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = ref.watch(cameraPermissionControllerProvider);
    final permissionController = ref.read(cameraPermissionControllerProvider.notifier);
    final autoRecognitionEnabled = ref.watch(autoRecognitionEnabledProvider);
    final showConfidence = ref.watch(showConfidenceProvider);
    final hapticEnabled = ref.watch(hapticOnRecognizeProvider);

    ref.listen<ScanState>(scanControllerProvider, (previous, next) {
      if ((previous?.isLocked ?? false) == false && next.isLocked && hapticEnabled) {
        HapticFeedback.lightImpact();
      }
    });

    ref.listen<bool>(autoRecognitionEnabledProvider, (previous, next) {
      if (!next) {
        ref.read(scanControllerProvider.notifier).stop();
        return;
      }
      _syncScanStateFromCurrentConditions();
    });

    ref.listen<PermissionStatus>(cameraPermissionControllerProvider, (previous, next) {
      final scan = ref.read(scanControllerProvider.notifier);
      if (next != PermissionStatus.granted) {
        scan.stop();
        return;
      }
      if (!ref.read(autoRecognitionEnabledProvider)) {
        return;
      }
      ref.read(cameraPreviewControllerProvider).whenData(scan.start);
    });

    ref.listen<AsyncValue<CameraController>>(cameraPreviewControllerProvider, (previous, next) {
      next.when(
        data: (controller) {
          if (!ref.read(autoRecognitionEnabledProvider)) {
            return;
          }
          final permission = ref.read(cameraPermissionControllerProvider);
          if (permission == PermissionStatus.granted) {
            ref.read(scanControllerProvider.notifier).start(controller);
          }
        },
        loading: () {},
        error: (_, __) => ref.read(scanControllerProvider.notifier).stop(),
      );
    });

    if (!_didInitialSync) {
      _didInitialSync = true;
      Future.microtask(_syncScanStateFromCurrentConditions);
    }

    if (permissionStatus != PermissionStatus.granted) {
      return Scaffold(
        body: SafeArea(
          child: _PermissionHero(
            status: permissionStatus,
            onGrantPressed: permissionController.requestPermission,
            onOpenSettingsPressed: openAppSettings,
            onBackPressed: context.pop,
          ),
        ),
      );
    }

    final cameraAsync = ref.watch(cameraPreviewControllerProvider);
    final scanState = ref.watch(scanControllerProvider);
    final lockedId = scanState.lockedMonumentId;
    final lockedMonument =
        lockedId == null ? null : ref.watch(monumentByIdProvider(lockedId));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _FullScreenPreview(cameraAsync: cameraAsync)),
          Positioned.fill(child: _ScanOverlay(scanState: scanState)),
          if (scanState.isLocked)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
            ),
          Positioned(
            top: 52,
            left: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: context.pop,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _BottomPanel(
                scanState: scanState,
                monument: lockedMonument,
                showConfidence: showConfidence,
                autoRecognitionEnabled: autoRecognitionEnabled,
                previewReady: cameraAsync.hasValue,
                onOpenDetails: lockedId == null
                    ? null
                    : () => context.push('${AppRoutePaths.monument}/$lockedId'),
                onRetry: () => ref.read(scanControllerProvider.notifier).retry(),
                onStartManual: () {
                  if (!cameraAsync.hasValue) {
                    return;
                  }
                  cameraAsync.whenData(
                    (controller) =>
                        ref.read(scanControllerProvider.notifier).start(controller),
                  );
                },
                onStopManual: () => ref.read(scanControllerProvider.notifier).stop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionHero extends StatelessWidget {
  const _PermissionHero({
    required this.status,
    required this.onGrantPressed,
    required this.onOpenSettingsPressed,
    required this.onBackPressed,
  });

  final PermissionStatus status;
  final VoidCallback onGrantPressed;
  final Future<bool> Function() onOpenSettingsPressed;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final isBlocked =
        status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.camera_alt_outlined,
            size: 108,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Permesso fotocamera richiesto',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isBlocked
                ? 'Il permesso è bloccato. Apri le impostazioni di sistema per abilitarlo.'
                : 'Concedi il permesso per avviare la preview live e il riconoscimento automatico.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isBlocked ? onOpenSettingsPressed : onGrantPressed,
              child: Text(isBlocked ? 'Apri impostazioni' : 'Concedi permesso'),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _FullScreenPreview extends StatelessWidget {
  const _FullScreenPreview({required this.cameraAsync});

  final AsyncValue<CameraController> cameraAsync;

  @override
  Widget build(BuildContext context) {
    return cameraAsync.when(
      data: (controller) => ColoredBox(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1080,
            height: controller.value.previewSize?.width ?? 1920,
            child: CameraPreview(controller),
          ),
        ),
      ),
      loading: () => const _PreviewFallback(
        icon: Icons.hourglass_bottom_rounded,
        message: 'Avvio fotocamera...',
      ),
      error: (error, _) => _PreviewFallback(
        icon: Icons.camera_alt_outlined,
        message: 'Preview non disponibile\n$error',
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 72),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.scanState});

  final ScanState scanState;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 120,
            left: 24,
            right: 24,
            child: Column(
              children: [
                const Text(
                  'Inquadra un monumento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scanState.isBusy ? 'Analisi…' : scanState.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  _CornerBracket(alignment: Alignment.topLeft, color: accent),
                  _CornerBracket(alignment: Alignment.topRight, color: accent),
                  _CornerBracket(alignment: Alignment.bottomLeft, color: accent),
                  _CornerBracket(alignment: Alignment.bottomRight, color: accent),
                  const Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 8, height: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment, required this.color});

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            top: isTop ? BorderSide(color: color, width: 4) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: 4) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: 4) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.scanState,
    required this.monument,
    required this.showConfidence,
    required this.autoRecognitionEnabled,
    required this.previewReady,
    required this.onOpenDetails,
    required this.onRetry,
    required this.onStartManual,
    required this.onStopManual,
  });

  final ScanState scanState;
  final Monument? monument;
  final bool showConfidence;
  final bool autoRecognitionEnabled;
  final bool previewReady;
  final VoidCallback? onOpenDetails;
  final VoidCallback onRetry;
  final VoidCallback onStartManual;
  final VoidCallback onStopManual;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: scanState.isLocked
          ? _LockedResultPanel(
              key: const ValueKey('locked-panel'),
              scanState: scanState,
              monument: monument,
              showConfidence: showConfidence,
              onOpenDetails: onOpenDetails,
              onRetry: onRetry,
            )
          : _StatusPill(
              key: const ValueKey('status-pill'),
              message: scanState.message,
              isBusy: scanState.isBusy,
              autoRecognitionEnabled: autoRecognitionEnabled,
              previewReady: previewReady,
              onStartManual: onStartManual,
              onStopManual: onStopManual,
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.message,
    required this.isBusy,
    required this.autoRecognitionEnabled,
    required this.previewReady,
    required this.onStartManual,
    required this.onStopManual,
  });

  final String message;
  final bool isBusy;
  final bool autoRecognitionEnabled;
  final bool previewReady;
  final VoidCallback onStartManual;
  final VoidCallback onStopManual;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBusy) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(message, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            if (!autoRecognitionEnabled) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonal(
                    onPressed: previewReady ? onStartManual : null,
                    child: const Text('Avvia scansione'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onStopManual,
                    child: const Text('Ferma'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LockedResultPanel extends StatelessWidget {
  const _LockedResultPanel({
    super.key,
    required this.scanState,
    required this.monument,
    required this.showConfidence,
    required this.onOpenDetails,
    required this.onRetry,
  });

  final ScanState scanState;
  final Monument? monument;
  final bool showConfidence;
  final VoidCallback? onOpenDetails;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: monument == null
                  ? Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    )
                  : Image.network(
                      monument!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(monument?.name ?? 'Monumento riconosciuto', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            monument?.description ?? 'Monumento non disponibile nel dataset locale.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          if (showConfidence) ...[
            const SizedBox(height: 6),
            Text(
              'Confidenza ${(scanState.lockedConfidence * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenDetails,
              child: const Text('Apri dettagli'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: onRetry, child: const Text('Riprova')),
          ),
        ],
      ),
    );
  }
}
