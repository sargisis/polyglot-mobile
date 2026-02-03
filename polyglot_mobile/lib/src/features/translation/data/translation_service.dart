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
  final String _apiKey = 'YOUR_API_KEY';
  final String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

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
        queryParameters: {
          'key': _apiKey,
        },
        data: {
          'q': text,
          'source': sourceLanguage.code,
          'target': targetLanguage.code,
          'format': 'text',
        },
      );

      if (response.statusCode == 200) {
        // Parse Google Translate API response structure
        // This is an example and might vary based on the specific API used
        final data = response.data;
        return data['data']['translations'][0]['translatedText'];
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
