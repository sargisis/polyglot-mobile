import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/features/translation/domain/translation_model.dart';
import 'src/features/translation/domain/language_model.dart';
import 'src/features/translation/presentation/screens/translation_screen.dart';
import 'src/features/translation/presentation/translation_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(LanguageAdapter());
  Hive.registerAdapter(TranslationAdapter());

  // Open Boxes
  final translationBox = await Hive.openBox<Translation>('translations');

  runApp(
    ProviderScope(
      overrides: [
        translationBoxProvider.overrideWithValue(translationBox),
      ],
      child: const PolyglotApp(),
    ),
  );
}

class PolyglotApp extends StatelessWidget {
  const PolyglotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyglot Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TranslationScreen(),
    );
  }
}
