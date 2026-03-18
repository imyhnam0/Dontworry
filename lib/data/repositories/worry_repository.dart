import 'package:hive_flutter/hive_flutter.dart';
import '../models/worry.dart';

class WorryRepository {
  static const _boxName = 'worries';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<Worry> getAll() {
    final worries = <Worry>[];
    for (final key in _box.keys) {
      final map = _box.get(key);
      if (map != null) {
        final worry = Worry.fromMap(map as Map);
        worry.updateStatus();
        worries.add(worry);
      }
    }
    worries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return worries;
  }

  Future<void> save(Worry worry) async {
    await _box.put(worry.id, worry.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Worry? getById(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    final worry = Worry.fromMap(map as Map);
    worry.updateStatus();
    return worry;
  }

  Future<void> updateStatus(String id, WorryStatus status) async {
    final worry = getById(id);
    if (worry == null) return;
    await save(worry.copyWith(status: status));
  }

  Future<void> saveReview({
    required String id,
    required ReviewAnswer answer,
    String? note,
  }) async {
    final worry = getById(id);
    if (worry == null) return;
    final updated = worry.copyWith(
      status: WorryStatus.resolved,
      reviewAnswer: answer,
      reviewNote: note,
      reviewedAt: DateTime.now(),
    );
    await save(updated);
  }
}
