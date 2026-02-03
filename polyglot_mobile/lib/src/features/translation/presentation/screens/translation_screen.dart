import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../translation_providers.dart';
import '../../domain/language_model.dart';

class TranslationScreen extends ConsumerWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationProvider);
    final notifier = ref.read(translationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polyglot'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to history
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Language Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LanguageButton(
                  language: state.sourceLanguage,
                  onPressed: () {
                    // Show language picker
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: notifier.swapLanguages,
                ),
                _LanguageButton(
                  language: state.targetLanguage,
                  onPressed: () {
                    // Show language picker
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Source Input
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter text',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 20),
                    maxLines: null,
                    onChanged: notifier.updateSourceText,
                    controller: TextEditingController(text: state.sourceText)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: state.sourceText.length)),
                  ),

                  const Divider(height: 32),

                  // Translated Output
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.error != null)
                    Text('Error: ${state.error}',
                        style: const TextStyle(color: Colors.red))
                  else if (state.translatedText != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translatedText!,
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  // Copy to clipboard
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {
                                  // Toggle favorite logic
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: notifier.translate,
        child: const Icon(Icons.translate),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final Language language;
  final VoidCallback onPressed;

  const _LanguageButton({required this.language, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        language.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
