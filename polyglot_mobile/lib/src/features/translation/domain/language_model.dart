import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'language_model.g.dart';

@HiveType(typeId: 0)
class Language extends Equatable {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  List<Object?> get props => [code, name, nativeName];

  factory Language.empty() =>
      const Language(code: '', name: '', nativeName: '');
}
