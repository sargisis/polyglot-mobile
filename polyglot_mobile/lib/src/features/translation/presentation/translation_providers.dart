import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import '../domain/translation_model.dart';
import '../domain/language_model.dart';
import '../data/translation_service.dart';
import '../data/translation_repository.dart';

// Dependencies
final dioProvider = Provider((ref) => Dio());

final translationServiceProvider = Provider<TranslationService>((ref) {
  return HttpTranslationService(ref.watch(dioProvider));
});

final translationBoxProvider = Provider<Box<Translation>>((ref) {
  throw UnimplementedError('Hive box must be initialized in main.dart');
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return TranslationRepository(ref.watch(translationBoxProvider));
});

// State
class TranslationState {
  final String sourceText;
  final String? translatedText;
  final Language sourceLanguage;
  final Language targetLanguage;
  final bool isLoading;
  final String? error;

  TranslationState({
    this.sourceText = '',
    this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.isLoading = false,
    this.error,
  });

  TranslationState copyWith({
    String? sourceText,
    String? translatedText,
    Language? sourceLanguage,
    Language? targetLanguage,
    bool? isLoading,
    String? error,
  }) {
    return TranslationState(
      sourceText: sourceText ?? this.sourceText,
      translatedText:
          translatedText, // Nullable update logic requires care, simplified here
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  final TranslationService _service;
  final TranslationRepository _repository;

  TranslationNotifier(this._service, this._repository)
      : super(TranslationState(
          sourceLanguage: const Language(
              code: 'en', name: 'English', nativeName: 'English'),
          targetLanguage: const Language(
              code: 'hy', name: 'Armenian', nativeName: 'Հայերեն'),
        ));

  void updateSourceText(String text) {
    state = state.copyWith(sourceText: text);
  }

  void setSourceLanguage(Language language) {
    state = state.copyWith(sourceLanguage: language);
  }

  void setTargetLanguage(Language language) {
    state = state.copyWith(targetLanguage: language);
  }

  Future<void> translate() async {
    if (state.sourceText.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.translate(
        text: state.sourceText,
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
      );

      state = state.copyWith(
        translatedText: result,
        isLoading: false,
      );

      // Save to history
      final translation = Translation(
        sourceText: state.sourceText,
        translatedText: result,
        sourceLanguageCode: state.sourceLanguage.code,
        targetLanguageCode: state.targetLanguage.code,
      );
      await _repository.saveTranslation(translation);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void swapLanguages() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
      sourceText: state.translatedText ?? '',
      translatedText: state.sourceText,
    );
  }
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final service = ref.watch(translationServiceProvider);
  final repository = ref.watch(translationRepositoryProvider);
  return TranslationNotifier(service, repository);
});

final historyProvider = Provider<List<Translation>>((ref) {
  final repository = ref.watch(translationRepositoryProvider);
  // This needs to be a Stream or StateNotifier to react to changes.
  // For simplicity, we'll assume the repo tracks changes or we use a separate Notifier for history.
  // In a real app, use ValueListenableBuilder or Stream from Hive.
  return repository.getHistory();
});
