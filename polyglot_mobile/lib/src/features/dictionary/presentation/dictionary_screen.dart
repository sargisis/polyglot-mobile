import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dictionary_service.dart';

final dictionarySearchProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(dictionaryServiceProvider);
  return service.searchWords(query);
});

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(dictionarySearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search words...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (words) {
                if (words.isEmpty && _query.isNotEmpty) {
                  return const Center(child: Text('No words found.'));
                }
                if (_query.isEmpty) {
                  return const Center(child: Text('Type to search words.'));
                }
                return ListView.separated(
                  itemCount: words.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return ListTile(
                      title: Text(word),
                      leading: CircleAvatar(child: Text(word[0])),
                      onTap: () {
                        // TODO: Navigate to word details or fill translation screen
                        // For now, just show a snackbar or go back with result
                        Navigator.pop(context, word);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
