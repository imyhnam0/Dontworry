import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worry.dart';
import '../repositories/worry_repository.dart';

final worryRepositoryProvider = Provider<WorryRepository>((ref) {
  return WorryRepository();
});

class WorryNotifier extends StateNotifier<List<Worry>> {
  final WorryRepository _repo;

  WorryNotifier(this._repo) : super([]) {
    load();
  }

  void load() {
    state = _repo.getAll();
  }

  Future<void> addWorry(Worry worry) async {
    await _repo.save(worry);
    load();
  }

  Future<void> deleteWorry(String id) async {
    await _repo.delete(id);
    load();
  }

  Future<void> saveReview({
    required String id,
    required ReviewAnswer answer,
    String? note,
  }) async {
    await _repo.saveReview(id: id, answer: answer, note: note);
    load();
  }

  Worry? getById(String id) => _repo.getById(id);

  List<Worry> get activeWorries =>
      state.where((w) => w.status == WorryStatus.active).toList();

  List<Worry> get reviewableWorries =>
      state.where((w) => w.status == WorryStatus.reviewable).toList();

  List<Worry> get resolvedWorries =>
      state.where((w) => w.status == WorryStatus.resolved).toList();
}

final worryProvider =
    StateNotifierProvider<WorryNotifier, List<Worry>>((ref) {
  final repo = ref.watch(worryRepositoryProvider);
  return WorryNotifier(repo);
});

// Filtered providers — watch the state list so they rebuild on changes
final activeWorriesProvider = Provider<List<Worry>>((ref) {
  final worries = ref.watch(worryProvider);
  return worries.where((w) => w.status == WorryStatus.active).toList();
});

final reviewableWorriesProvider = Provider<List<Worry>>((ref) {
  final worries = ref.watch(worryProvider);
  return worries.where((w) => w.status == WorryStatus.reviewable).toList();
});

final resolvedWorriesProvider = Provider<List<Worry>>((ref) {
  final worries = ref.watch(worryProvider);
  return worries.where((w) => w.status == WorryStatus.resolved).toList();
});
