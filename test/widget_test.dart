import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:inquadra/app/inquadra_app.dart';
import 'package:inquadra/shared/startup/startup_requirements_checker.dart';
import 'package:inquadra/features/startup/presentation/startup_gate_screen.dart';

class _FakeStartupRequirementsChecker extends StartupRequirementsChecker {
  const _FakeStartupRequirementsChecker(this._status);

  final StartupRequirementsStatus _status;

  @override
  Future<StartupRequirementsStatus> check() async => _status;
}

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required StartupRequirementsStatus startupStatus,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupRequirementsCheckerProvider.overrideWithValue(
            _FakeStartupRequirementsChecker(startupStatus),
          ),
        ],
        child: const InQuadraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  const allOkStatus = StartupRequirementsStatus(
    hasInternet: true,
    locationServiceEnabled: true,
    locationPermission: PermissionStatus.granted,
    cameraPermission: PermissionStatus.granted,
  );

  testWidgets('StartupGate non crasha e porta in Home con requisiti soddisfatti', (
    tester,
  ) async {
    await pumpApp(tester, startupStatus: allOkStatus);

    expect(find.text('InQuadra'), findsOneWidget);
    expect(find.text('Avvia fotocamera'), findsOneWidget);
  });

  testWidgets('StartupGate mostra requisiti mancanti quando internet non disponibile', (
    tester,
  ) async {
    const missingStatus = StartupRequirementsStatus(
      hasInternet: false,
      locationServiceEnabled: true,
      locationPermission: PermissionStatus.granted,
      cameraPermission: PermissionStatus.granted,
    );

    await pumpApp(tester, startupStatus: missingStatus);

    expect(find.text('Requisiti iniziali'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.textContaining('Nessuna connessione disponibile'), findsOneWidget);
    expect(find.text('Apri impostazioni rete'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
