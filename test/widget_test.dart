import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inquadra/app/inquadra_app.dart';

void main() {
  testWidgets('Mostra HomeScreen con titolo InQuadra', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    expect(find.text('InQuadra'), findsOneWidget);
    expect(find.text('Avvia fotocamera'), findsOneWidget);
  });

  testWidgets('Naviga verso CameraScreen da HomeScreen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    await tester.tap(find.text('Avvia fotocamera'));
    await tester.pumpAndSettle();

    expect(find.text('Fotocamera'), findsOneWidget);
    expect(find.text('Simula riconoscimento'), findsOneWidget);
  });

  testWidgets('Naviga verso lista Monumenti da HomeScreen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    await tester.tap(find.text('Monumenti'));
    await tester.pumpAndSettle();

    expect(find.text('Monumenti'), findsWidgets);
    expect(find.text('Obelisco'), findsOneWidget);
  });

  testWidgets('Back da Camera torna a Home', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    await tester.tap(find.text('Avvia fotocamera'));
    await tester.pumpAndSettle();
    expect(find.text('Fotocamera'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('InQuadra'), findsOneWidget);
  });

  testWidgets('Scheda monumento mostra sezione mappa e vicinanze', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    await tester.tap(find.text('Monumenti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Obelisco'));
    await tester.pumpAndSettle();

    expect(find.text('Mappa e monumenti vicini'), findsOneWidget);
    expect(find.textContaining('Raggio vicinanza impostato a 200m'), findsOneWidget);
    expect(find.text('Monumenti vicini (<= 200m)'), findsOneWidget);
  });

  testWidgets('Back da dettaglio monumento torna a lista Monumenti', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );

    await tester.tap(find.text('Monumenti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Obelisco'));
    await tester.pumpAndSettle();

    expect(find.text('Scheda Monumento'), findsOneWidget);
    expect(find.text('Torna alla fotocamera'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Monumenti'), findsWidgets);
    expect(find.text('Obelisco'), findsOneWidget);
  });
}
