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
}
