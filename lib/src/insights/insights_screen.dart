import 'package:flutter/material.dart';
import 'package:prokopa/src/insights/insight_store.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.store});

  final InsightStore store;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<LocalInsight>? _insights;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final insights = await widget.store.refresh();
    if (mounted) {
      setState(() => _insights = insights);
    }
  }

  Future<void> _dismiss(LocalInsight insight) async {
    await widget.store.dismiss(insight);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final insights = _insights;
    return SafeArea(
      child: insights == null
          ? const Center(child: CircularProgressIndicator())
          : insights.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Belum ada insight.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Insight akan muncul saat catatan lokal sudah cukup untuk diamati.',
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: insights.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final insight = insights[index];
                return ListTile(
                  title: Text(insight.observation),
                  subtitle: Text(
                    '${insight.evidence}\n${insight.action ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: () => _dismiss(insight),
                    icon: const Icon(Icons.close),
                    tooltip: 'Sembunyikan insight',
                  ),
                );
              },
            ),
    );
  }
}
