import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../logging/app_logger.dart';
import '../startup/startup_requirements_checker.dart';

final startupRequirementsCheckerProvider = Provider<StartupRequirementsChecker>(
  (ref) => const StartupRequirementsChecker(),
);

enum _StartupDialogAction { openSettings, exit }

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndGate();
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
      _checkAndGate(force: true);
    }
  }

  Future<void> _checkAndGate({bool force = false}) async {
    if ((_checking || _dialogOpen) && !force) {
      return;
    }
    _checking = true;

    try {
      final checker = ref.read(startupRequirementsCheckerProvider);
      final status = await checker.check();

      if (status.allSatisfied || !mounted) {
        return;
      }

      final action = await _showBlockingDialog(status);

      if (action == _StartupDialogAction.openSettings) {
        await openAppSettings();
        return;
      }

      await _handleExitAction();
    } catch (error) {
      AppLogger.error('Errore controllo requisiti startup: $error');
    } finally {
      _checking = false;
    }
  }

  Future<_StartupDialogAction> _showBlockingDialog(
    StartupRequirementsStatus status,
  ) async {
    _dialogOpen = true;

    final action = await showDialog<_StartupDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final missingItems = status.missingRequirements();
        return AlertDialog(
          title: const Text('Permessi necessari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Per continuare abilita i seguenti requisiti:'),
              const SizedBox(height: 8),
              for (final item in missingItems) Text('• $item'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_StartupDialogAction.exit),
              child: const Text('Esci'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_StartupDialogAction.openSettings),
              child: const Text('Apri impostazioni'),
            ),
          ],
        );
      },
    );

    _dialogOpen = false;
    return action ?? _StartupDialogAction.exit;
  }

  Future<void> _handleExitAction() async {
    if (!mounted) {
      return;
    }

    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return;
    }

    if (Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Non è possibile chiudere l’app automaticamente su iOS.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
