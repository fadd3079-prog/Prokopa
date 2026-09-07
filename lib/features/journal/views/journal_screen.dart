import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/features/journal/providers/journal_providers.dart';
import 'package:habitflow/features/journal/widgets/journal_card.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search journals...',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (_) => setState(() {}),
              )
            : const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/journal/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching && _searchController.text.isNotEmpty) {
      final searchAsyncValue = ref.watch(journalSearchProvider(_searchController.text));
      return searchAsyncValue.when(
        data: (journals) => _buildJournalList(journals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      );
    }

    final journalsAsyncValue = ref.watch(allJournalsProvider);
    return journalsAsyncValue.when(
      data: (journals) => _buildJournalList(journals),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildJournalList(List<Journal> journals) {
    if (journals.isEmpty) {
      return const Center(
        child: Text('No journal entries found.'),
      );
    }

    return ListView.builder(
      itemCount: journals.length,
      itemBuilder: (context, index) {
        final journal = journals[index];
        return JournalCard(
          journal: journal,
          onTap: () => context.push('/journal/${journal.id}'),
        );
      },
    );
  }
}
