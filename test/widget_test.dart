import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inquadra/app/inquadra_app.dart';

void main() {
  testWidgets('avvio diretto su Home senza gate, con CTA fotocamera visibile', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: InQuadraApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Inquadra un monumento'), findsOneWidget);
    expect(find.text('Apri fotocamera'), findsOneWidget);
    expect(find.text('Vicino a te'), findsOneWidget);
    expect(find.text('Tutti i monumenti'), findsOneWidget);
  });
}
