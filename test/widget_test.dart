import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}
