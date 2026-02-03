import 'package:dio/dio.dart';
import '../domain/translation_model.dart';
import '../domain/language_model.dart';

abstract class TranslationService {
  Future<String> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  });

  Future<List<Language>> getSupportedLanguages();
}

class HttpTranslationService implements TranslationService {
  final Dio _dio;
  // TODO: Add API Key and Base URL
  // Base URL for Android emulator to access host localhost
  // For iOS/Physical devices, use your machine's LAN IP
  final String _baseUrl = 'http://10.0.2.2:8080/api/translate';

  HttpTranslationService(this._dio);

  @override
  Future<String> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'text': text,
          'source_lang': sourceLanguage.code,
          'target_lang': targetLanguage.code,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final translatedList = List<String>.from(data['translated']);
        return translatedList.join('\n');
      } else {
        throw Exception('Failed to translate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation API Error: $e');
    }
  }

  @override
  Future<List<Language>> getSupportedLanguages() async {
    // Mock implementation for supported languages
    // In a real app, you might fetch this from the API
    return const [
      Language(code: 'en', name: 'English', nativeName: 'English'),
      Language(code: 'es', name: 'Spanish', nativeName: 'Español'),
      Language(code: 'fr', name: 'French', nativeName: 'Français'),
      Language(code: 'de', name: 'German', nativeName: 'Deutsch'),
      Language(code: 'it', name: 'Italian', nativeName: 'Italiano'),
      Language(code: 'ja', name: 'Japanese', nativeName: '日本語'),
      Language(code: 'ko', name: 'Korean', nativeName: '한국어'),
      Language(code: 'ru', name: 'Russian', nativeName: 'Русский'),
      Language(code: 'zh', name: 'Chinese', nativeName: '中文'),
    ];
  }
}
