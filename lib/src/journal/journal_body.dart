import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/insights/journal_insight_summary.dart';
import 'package:prokopa/src/journal/journal_entry.dart';

class JournalBody extends StatelessWidget {
  const JournalBody({
    super.key,
    required this.entries,
    required this.error,
    required this.hasMore,
    required this.isLoadingMore,
    required this.insightStore,
    required this.refreshVersion,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onOpen,
    required this.onCreate,
  });

  final List<JournalEntryPreview>? entries;
  final String? error;
  final bool hasMore;
  final bool isLoadingMore;
  final InsightStore insightStore;
  final int refreshVersion;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<JournalEntryPreview> onOpen;
  final ValueChanged<JournalEntryType> onCreate;

  @override
  Widget build(BuildContext context) {
    final currentEntries = entries;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: JournalInsightSummary(
              store: insightStore,
              refreshVersion: refreshVersion,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                ProkopaSpacing.xl,
                0,
                ProkopaSpacing.xl,
                ProkopaSpacing.md,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  'Catatanmu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          if (currentEntries == null && error == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Memuat catatan jurnal',
                ),
              ),
            )
          else if (error case final message?)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _JournalError(message: message, onRetry: onRefresh),
            )
          else if (currentEntries!.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _JournalEmpty(onCreate: onCreate),
            )
          else
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                ProkopaSpacing.xl,
                0,
                ProkopaSpacing.xl,
                ProkopaSpacing.huge,
              ),
              sliver: SliverList.separated(
                itemCount:
                    currentEntries.length + (hasMore || isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: ProkopaSpacing.md),
                itemBuilder: (context, index) {
                  if (index == currentEntries.length) {
                    return Center(
                      child: isLoadingMore
                          ? const CircularProgressIndicator(
                              semanticsLabel: 'Memuat catatan berikutnya',
                            )
                          : OutlinedButton(
                              onPressed: onLoadMore,
                              child: const Text('Muat lebih banyak'),
                            ),
                    );
                  }
                  final entry = currentEntries[index];
                  return _JournalCard(
                    key: ValueKey(entry.id),
                    entry: entry,
                    onTap: () => onOpen(entry),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry, required this.onTap, super.key});

  final JournalEntryPreview entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = entry.title?.isNotEmpty == true
        ? entry.title!
        : 'Tanpa judul';
    final preview = entry.bodyPreview.isEmpty
        ? 'Draf kosong'
        : entry.bodyPreview.replaceAll('\n', ' ');
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: ProkopaRadius.lgBorder,
        child: Padding(
          padding: ProkopaSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  if (entry.status == JournalEntryStatus.draft) ...[
                    const SizedBox(width: ProkopaSpacing.sm),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: ProkopaRadius.smBorder,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ProkopaSpacing.sm,
                          vertical: ProkopaSpacing.xs,
                        ),
                        child: Text('Draf', style: theme.textTheme.labelSmall),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: ProkopaSpacing.sm),
              Text(
                preview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalError extends StatelessWidget {
  const _JournalError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: ProkopaSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _JournalEmpty extends StatelessWidget {
  const _JournalEmpty({required this.onCreate});

  final ValueChanged<JournalEntryType> onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.book_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Text('Belum ada catatan.', style: theme.textTheme.titleLarge),
            const SizedBox(height: ProkopaSpacing.sm),
            Text(
              'Tulis bebas atau gunakan satu pertanyaan sebagai awal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            FilledButton.icon(
              onPressed: () => onCreate(JournalEntryType.free),
              icon: const ExcludeSemantics(child: Icon(Icons.edit)),
              label: const Text('Tulis jurnal'),
            ),
          ],
        ),
      ),
    );
  }
}
