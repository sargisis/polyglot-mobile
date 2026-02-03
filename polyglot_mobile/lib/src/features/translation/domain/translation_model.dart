import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'translation_model.g.dart';

@HiveType(typeId: 1)
class Translation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sourceText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLanguageCode;

  @HiveField(4)
  final String targetLanguageCode;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool isFavorite;

  Translation({
    String? id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    DateTime? timestamp,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Translation copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguageCode,
    String? targetLanguageCode,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Translation(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
