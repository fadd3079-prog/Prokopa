import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/insights/insight_store.dart';

class JournalInsightSummary extends StatefulWidget {
  const JournalInsightSummary({
    super.key,
    required this.store,
    this.refreshVersion = 0,
  });

  final InsightStore store;
  final int refreshVersion;

  @override
  State<JournalInsightSummary> createState() => _JournalInsightSummaryState();
}

class _JournalInsightSummaryState extends State<JournalInsightSummary> {
  List<LocalInsight>? _insights;
  String? _error;
  var _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant JournalInsightSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
  }

  Future<void> _reload() async {
    try {
      final insights = await widget.store.refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _insights = insights;
        _error = null;
        if (insights.length <= 1) {
          _isExpanded = false;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Insight belum dapat dimuat.');
      }
    }
  }

  Future<void> _dismiss(LocalInsight insight) async {
    await widget.store.dismiss(insight);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final insights = _insights;
    final visible = insights == null || insights.isEmpty
        ? const <LocalInsight>[]
        : _isExpanded
        ? insights
        : insights.take(1).toList();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ProkopaSpacing.xl,
        0,
        ProkopaSpacing.xl,
        ProkopaSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Insight jurnal',
                image: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: ProkopaRadius.mdBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(ProkopaSpacing.md),
                    child: ExcludeSemantics(
                      child: Icon(
                        Icons.auto_graph_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ProkopaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Insight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: ProkopaSpacing.xs),
                    Text(
                      'Pola singkat dari catatan dan kebiasaanmu.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ProkopaSpacing.md),
          if (insights == null && _error == null)
            const LinearProgressIndicator(
              semanticsLabel: 'Memuat insight jurnal',
            )
          else if (_error case final error?)
            _InsightError(message: error, onRetry: _reload)
          else if (insights!.isEmpty)
            const _EmptyInsights()
          else ...[
            for (final insight in visible) ...[
              _InsightCard(
                insight: insight,
                onDismiss: () => _dismiss(insight),
              ),
              if (insight != visible.last)
                const SizedBox(height: ProkopaSpacing.md),
            ],
            if (insights.length > 1) ...[
              const SizedBox(height: ProkopaSpacing.sm),
              TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded
                      ? 'Ringkas insight'
                      : 'Tampilkan semua insight (${insights.length})',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.onDismiss});

  final LocalInsight insight;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    insight.observation,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  tooltip: 'Sembunyikan insight',
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: const ExcludeSemantics(child: Icon(Icons.close)),
                ),
              ],
            ),
            const SizedBox(height: ProkopaSpacing.sm),
            Text(
              insight.evidence,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (insight.action case final action?) ...[
              const SizedBox(height: ProkopaSpacing.md),
              Text(action, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightError extends StatelessWidget {
  const _InsightError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: ProkopaSpacing.sm),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  const _EmptyInsights();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Text(
          'Belum ada pola yang cukup kuat. Insight akan muncul setelah catatan lokal mencukupi.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
