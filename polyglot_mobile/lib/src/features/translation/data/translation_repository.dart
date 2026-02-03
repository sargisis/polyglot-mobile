import '../domain/translation_model.dart';
import '../../../core/utils/hive_repository.dart';

class TranslationRepository extends HiveRepository<Translation> {
  TranslationRepository(super.box);

  Future<void> saveTranslation(Translation translation) async {
    await add(translation.id, translation);
  }

  List<Translation> getHistory() {
    // Return most recent first
    final list = getAll();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<Translation> getFavorites() {
    final list = getAll().where((t) => t.isFavorite).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> toggleFavorite(String id) async {
    final translation = get(id);
    if (translation != null) {
      final updated = translation.copyWith(isFavorite: !translation.isFavorite);
      await saveTranslation(updated);
    }
  }

  Future<void> deleteTranslation(String id) async {
    await box.delete(id);
  }
}
