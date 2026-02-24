import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/router.dart';
import '../../../features/location/application/location_controller.dart';
import '../../../shared/logging/app_logger.dart';
import '../../../shared/startup/startup_requirements_checker.dart';

final startupRequirementsCheckerProvider = Provider<StartupRequirementsChecker>(
  (ref) => const StartupRequirementsChecker(),
);

class StartupGateScreen extends ConsumerStatefulWidget {
  const StartupGateScreen({super.key});

  @override
  ConsumerState<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends ConsumerState<StartupGateScreen>
    with WidgetsBindingObserver {
  StartupRequirementsStatus? _status;
  bool _isChecking = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    if (!mounted) {
      return;
    }

    setState(() => _isChecking = true);

    try {
      final checker = ref.read(startupRequirementsCheckerProvider);
      final status = await checker.check();

      if (!mounted) {
        return;
      }

      setState(() {
        _status = status;
        _isChecking = false;
      });

      if (status.allSatisfied) {
        unawaited(ref.read(locationControllerProvider.notifier).bootstrap());
        context.go(AppRoutePaths.home);
      }
    } catch (error) {
      AppLogger.error('Errore verifica requisiti startup: $error');
      if (!mounted) {
        return;
      }
      setState(() => _isChecking = false);
    }
  }

  Future<void> _requestCameraPermission() async {
    await _withBusyGuard(() async {
      final current = await Permission.camera.status;
      if (current.isGranted) {
        return;
      }

      final requested = await Permission.camera.request();
      if (requested.isPermanentlyDenied) {
        await openAppSettings();
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    await _withBusyGuard(() async {
      final current = await Permission.locationWhenInUse.status;
      if (current.isGranted) {
        return;
      }

      final requested = await Permission.locationWhenInUse.request();
      if (requested.isPermanentlyDenied) {
        await openAppSettings();
      }
    });
  }

  Future<void> _openNetworkSettings() async {
    await _withBusyGuard(() async {
      await openAppSettings();
    });
  }

  Future<void> _openLocationSettings() async {
    await _withBusyGuard(() async {
      await Geolocator.openLocationSettings();
    });
  }

  Future<void> _withBusyGuard(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
      await _refreshStatus();
    }
  }

  Future<void> _handleExitPressed() async {
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Non è possibile chiudere l’app automaticamente su iOS.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return Scaffold(
      appBar: AppBar(title: const Text('Requisiti iniziali')),
      body: SafeArea(
        child: _isChecking || status == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Per utilizzare InQuadra devi soddisfare tutti i requisiti essenziali.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _RequirementCard(
                    title: 'Internet',
                    isOk: status.hasInternet,
                    okText: 'Connesso (Wi-Fi o dati mobili).',
                    koText: 'Nessuna connessione disponibile.',
                    actionLabel: 'Apri impostazioni rete',
                    onAction: _openNetworkSettings,
                  ),
                  const SizedBox(height: 12),
                  _RequirementCard(
                    title: 'Servizi posizione (GPS)',
                    isOk: status.locationServiceEnabled,
                    okText: 'Servizio posizione attivo.',
                    koText: 'Servizio posizione disattivato.',
                    actionLabel: 'Apri impostazioni posizione',
                    onAction: _openLocationSettings,
                  ),
                  const SizedBox(height: 12),
                  _RequirementCard(
                    title: 'Permesso posizione',
                    isOk: status.hasLocationPermission,
                    okText: 'Permesso posizione concesso.',
                    koText: status.locationPermission.isPermanentlyDenied
                        ? 'Permesso negato in modo permanente.'
                        : 'Permesso non concesso.',
                    actionLabel: status.locationPermission.isPermanentlyDenied
                        ? 'Apri impostazioni app'
                        : 'Concedi permesso',
                    onAction: _requestLocationPermission,
                  ),
                  const SizedBox(height: 12),
                  _RequirementCard(
                    title: 'Permesso fotocamera',
                    isOk: status.hasCameraPermission,
                    okText: 'Permesso fotocamera concesso.',
                    koText: status.cameraPermission.isPermanentlyDenied
                        ? 'Permesso negato in modo permanente.'
                        : 'Permesso non concesso.',
                    actionLabel: status.cameraPermission.isPermanentlyDenied
                        ? 'Apri impostazioni app'
                        : 'Concedi permesso',
                    onAction: _requestCameraPermission,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _refreshStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _isBusy ? null : _handleExitPressed,
                    child: const Text('Esci'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({
    required this.title,
    required this.isOk,
    required this.okText,
    required this.koText,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final bool isOk;
  final String okText;
  final String koText;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isOk ? Icons.check_circle : Icons.error_outline),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(isOk ? okText : koText),
            if (!isOk) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
