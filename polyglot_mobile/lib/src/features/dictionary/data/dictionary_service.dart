import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../translation/presentation/translation_providers.dart';

final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return HttpDictionaryService(ref.watch(dioProvider));
});

abstract class DictionaryService {
  Future<List<String>> searchWords(String query);
}

class HttpDictionaryService implements DictionaryService {
  final Dio _dio;
  // Use same base URL as translation service but different endpoint
  final String _baseUrl = 'http://10.0.2.2:8080/api/search';

  HttpDictionaryService(this._dio);

  @override
  Future<List<String>> searchWords(String query) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to search words: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Dictionary API Error: $e');
    }
  }
}
