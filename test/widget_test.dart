import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:inquadra/app/inquadra_app.dart';
import 'package:inquadra/shared/startup/startup_requirements_checker.dart';
import 'package:inquadra/shared/widgets/startup_permission_requester.dart';

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

  testWidgets('Mostra HomeScreen quando requisiti startup sono soddisfatti', (
    tester,
  ) async {
    await pumpApp(tester, startupStatus: allOkStatus);

    expect(find.text('InQuadra'), findsOneWidget);
    expect(find.text('Avvia fotocamera'), findsOneWidget);
  });

  testWidgets('Mostra dialog bloccante quando manca un requisito startup', (
    tester,
  ) async {
    const missingStatus = StartupRequirementsStatus(
      hasInternet: false,
      locationServiceEnabled: true,
      locationPermission: PermissionStatus.granted,
      cameraPermission: PermissionStatus.granted,
    );

    await pumpApp(tester, startupStatus: missingStatus);

    expect(find.text('Permessi necessari'), findsOneWidget);
    expect(
      find.textContaining('Connessione internet assente (Wi-Fi o dati mobili).'),
      findsOneWidget,
    );
    expect(find.text('Apri impostazioni'), findsOneWidget);
    expect(find.text('Esci'), findsOneWidget);
  });

  testWidgets('Naviga verso CameraScreen da HomeScreen', (tester) async {
    await pumpApp(tester, startupStatus: allOkStatus);

    await tester.tap(find.text('Avvia fotocamera'));
    await tester.pumpAndSettle();

    expect(find.text('Fotocamera'), findsOneWidget);
    expect(find.text('Simula riconoscimento'), findsOneWidget);
  });

  testWidgets('Naviga verso lista Monumenti da HomeScreen', (tester) async {
    await pumpApp(tester, startupStatus: allOkStatus);

    await tester.tap(find.text('Monumenti'));
    await tester.pumpAndSettle();

    expect(find.text('Monumenti'), findsWidgets);
    expect(find.text('Obelisco'), findsOneWidget);
  });
}
