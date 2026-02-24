import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../location/application/location_controller.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoRecognition = ref.watch(autoRecognitionEnabledProvider);
    final showConfidence = ref.watch(showConfidenceProvider);
    final haptic = ref.watch(hapticOnRecognizeProvider);
    final locationState = ref.watch(locationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Riconoscimento',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.auto_awesome),
                title: const Text('Riconoscimento automatico'),
                subtitle: const Text('Avvia la scansione automaticamente in camera.'),
                value: autoRecognition,
                onChanged: (value) =>
                    ref.read(autoRecognitionEnabledProvider.notifier).state = value,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.percent),
                title: const Text('Mostra confidenza'),
                subtitle: const Text('Visualizza la percentuale di confidenza.'),
                value: showConfidence,
                onChanged: (value) =>
                    ref.read(showConfidenceProvider.notifier).state = value,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: const Text('Feedback aptico'),
                subtitle: const Text('Vibrazione leggera quando il riconoscimento si blocca.'),
                value: haptic,
                onChanged: (value) =>
                    ref.read(hapticOnRecognizeProvider.notifier).state = value,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Posizione',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.my_location),
                title: const Text('Posizione'),
                subtitle: const Text('Usa la posizione per ordinare i monumenti vicini.'),
                value: locationState.enabled,
                onChanged: (value) {
                  final notifier = ref.read(locationControllerProvider.notifier);
                  if (value) {
                    notifier.enable();
                  } else {
                    notifier.disable();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  _locationStatusText(locationState),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (locationState.permanentlyDenied)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: openAppSettings,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Apri impostazioni app'),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _locationStatusText(LocationState state) {
    if (state.isLoading) {
      return 'Recupero posizione in corso...';
    }
    if (state.errorMessage != null) {
      return state.errorMessage!;
    }
    if (state.enabled && state.permissionGranted && state.serviceEnabled) {
      if (state.latitude != null && state.longitude != null) {
        return 'Posizione attiva (${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)})';
      }
      return 'Posizione attiva';
    }
    return 'Posizione non attiva';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
