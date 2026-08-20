import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inquadra/app/inquadra_app.dart';
import 'package:inquadra/app/router.dart';
import 'package:inquadra/features/monuments/presentation/monuments_list_screen.dart';

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

  for (final entry in const <String, String>{
    'cenotafio-sorbo-tagliacozzo': 'Cenotafio',
    'chiesa-santa-maria-delle-grazie-sorbo-tagliacozzo':
        'Chiesa di Santa Maria delle Grazie',
    'colonna-miliaria-sorbo-tagliacozzo': 'Colonna miliaria',
  }.entries) {
    testWidgets('apre la scheda ${entry.value} tramite id', (tester) async {
      appRouter.go('${AppRoutePaths.monument}/${entry.key}');
      await tester.pumpWidget(const ProviderScope(child: InQuadraApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(entry.value), findsWidgets);
      expect(find.text('Piazza Miliaria, Sorbo di Tagliacozzo'), findsOneWidget);
      expect(find.text('Monumento non trovato.'), findsNothing);
    });
  }

  for (final name in const [
    'Cenotafio',
    'Chiesa di Santa Maria delle Grazie',
    'Colonna miliaria',
  ]) {
    testWidgets('cerca $name nell’elenco monumenti', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MonumentsListScreen()),
        ),
      );

      await tester.enterText(find.byType(SearchBar), name);
      await tester.pump();

      expect(find.text(name), findsOneWidget);
      expect(find.text('Sorbo di Tagliacozzo · Piazza Miliaria'), findsOneWidget);
    });
  }
}
