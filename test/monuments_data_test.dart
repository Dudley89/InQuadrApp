import 'package:flutter_test/flutter_test.dart';
import 'package:inquadra/features/camera/data/local_monument_recognition_profiles.dart';
import 'package:inquadra/features/monuments/application/monuments_repository.dart';
import 'package:inquadra/features/monuments/data/local_monuments.dart';
import 'package:inquadra/features/monuments/domain/monument.dart';

void main() {
  const locality = 'Sorbo di Tagliacozzo';
  const address = 'Piazza Miliaria';
  const expected = <String, int>{
    'Cenotafio': 1004,
    'Chiesa di Santa Maria delle Grazie': 1005,
    'Colonna miliaria': 1006,
  };
  const repository = MonumentsRepository();

  group('dataset monumenti di Sorbo di Tagliacozzo', () {
    test('carica esattamente i tre monumenti con località e indirizzo', () {
      final monuments = repository.getByLocality(locality);

      expect(monuments, hasLength(3));
      expect(monuments.map((item) => item.name).toSet(), expected.keys.toSet());
      for (final monument in monuments) {
        expect(monument.address, address);
        expect(monument.municipality, 'Tagliacozzo');
        expect(monument.province, 'L’Aquila');
        expect(monument.region, 'Abruzzo');
        expect(monument.country, 'Italia');
        expect(monument.latitude, isNot(0));
        expect(monument.longitude, isNot(0));
      }
    });

    test('mantiene univoci id e idGlobal nell’intero dataset', () {
      expect(
        localMonuments.map((item) => item.id).toSet(),
        hasLength(localMonuments.length),
      );
      expect(
        localMonuments.map((item) => item.idGlobal).toSet(),
        hasLength(localMonuments.length),
      );
      for (final entry in expected.entries) {
        expect(
          localMonuments.singleWhere((item) => item.name == entry.key).idGlobal,
          entry.value,
        );
      }
    });

    test('trova ogni nuovo monumento per nome e la località completa', () {
      for (final name in expected.keys) {
        expect(repository.search(name).single.name, name);
      }
      expect(repository.search(locality), hasLength(3));
    });

    test('risolve ogni scheda tramite id', () {
      for (final monument in repository.getByLocality(locality)) {
        expect(repository.getById(monument.id), same(monument));
      }
    });

    test('deserializza i nuovi campi e gestisce quelli opzionali assenti', () {
      for (final monument in repository.getByLocality(locality)) {
        final decoded = Monument.fromJson({
          'id': monument.id,
          'idGlobal': monument.idGlobal,
          'name': monument.name,
          'description': monument.description,
          'latitude': monument.latitude,
          'longitude': monument.longitude,
          'locality': monument.locality,
          'address': monument.address,
          'municipality': monument.municipality,
          'province': monument.province,
          'region': monument.region,
          'country': monument.country,
        });

        expect(decoded.locality, locality);
        expect(decoded.address, address);
        expect(decoded.deepDive, isEmpty);
        expect(decoded.imageUrl, isEmpty);
        expect(decoded.accessibility, isEmpty);
      }
    });

    test('resta retrocompatibile con un record privo dei campi di località', () {
      final decoded = Monument.fromJson({
        'id': 'record-esistente',
        'idGlobal': 1,
        'name': 'Record esistente',
        'description': 'Descrizione',
        'deepDive': 'Approfondimento',
        'imageUrl': 'https://example.test/image.jpg',
        'accessibility': <String>['Testo grande'],
        'latitude': 42,
        'longitude': 13,
      });

      expect(decoded.locality, isNull);
      expect(decoded.address, isNull);
      expect(decoded.deepDive, 'Approfondimento');
    });

    test('mantiene coerenti immagini e profili senza embedding fittizi', () {
      for (final monument in repository.getByLocality(locality)) {
        final profile = localMonumentRecognitionProfiles.singleWhere(
          (item) => item.monumentId == monument.id,
        );
        expect(monument.imageUrl, isNotEmpty);
        expect(profile.referenceImages, [monument.imageUrl]);
        expect(profile.embeddings, isEmpty);
      }
      expect(localMonumentRecognitionProfiles, hasLength(localMonuments.length));
    });
  });
}
