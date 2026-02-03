import 'package:hive/hive.dart';

abstract class HiveRepository<T> {
  final Box<T> box;

  HiveRepository(this.box);

  Future<void> add(String key, T item) async {
    await box.put(key, item);
  }

  T? get(String key) {
    return box.get(key);
  }

  List<T> getAll() {
    return box.values.toList();
  }

  Future<void> deleteItem(String key) async {
    await box.delete(key);
  }

  Future<void> clear() async {
    await box.clear();
  }
}
