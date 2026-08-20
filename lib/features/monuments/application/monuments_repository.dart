import '../data/local_monuments.dart';
import '../domain/monument.dart';

class MonumentsRepository {
  const MonumentsRepository();

  List<Monument> getAll() => localMonuments;

  Monument? getById(String id) {
    for (final monument in localMonuments) {
      if (monument.id == id) {
        return monument;
      }
    }
    return null;
  }

  Monument get featured => localMonuments.first;

  List<Monument> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return localMonuments.where((monument) {
      final searchableValues = <String?>[
        monument.name,
        monument.locality,
        monument.address,
        monument.municipality,
      ];
      return searchableValues.any(
        (value) => value?.toLowerCase().contains(normalizedQuery) ?? false,
      );
    }).toList(growable: false);
  }

  List<Monument> getByLocality(String locality) {
    final normalizedLocality = locality.trim().toLowerCase();
    return localMonuments
        .where((monument) => monument.locality?.toLowerCase() == normalizedLocality)
        .toList(growable: false);
  }
}
