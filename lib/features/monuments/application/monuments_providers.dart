import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/monument.dart';
import 'monuments_repository.dart';

final monumentsRepositoryProvider = Provider<MonumentsRepository>((ref) {
  return const MonumentsRepository();
});

final monumentsListProvider = Provider<List<Monument>>((ref) {
  return ref.watch(monumentsRepositoryProvider).getAll();
});

final featuredMonumentProvider = Provider<Monument>((ref) {
  return ref.watch(monumentsRepositoryProvider).featured;
});

final monumentByIdProvider = Provider.family<Monument?, String>((ref, id) {
  return ref.watch(monumentsRepositoryProvider).getById(id);
});
