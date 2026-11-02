import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/stats.dart';
import '../models/health_record.dart';
import '../state/records_provider.dart';
import '../state/settings_provider.dart';
import 'widgets.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});
  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RecordsProvider>();
    final sp = context.watch<SettingsProvider>();
    final t = Theme.of(context);
    final now = DateTime.now();
    if (rp.loading) return const Center(child: CircularProgressIndicator());
    if (rp.records.isEmpty) {
      return const EmptyState(icon: Icons.insights_outlined, title: 'Nothing to summarise', message: 'Add some records and your trends will appear here.');
    }
    final today = rp.records.where((r) => r.date == fmtDate(now)).firstOrNull;
    final cur = Stats.window(rp.records, now, _days);
    final prev = Stats.window(rp.records, DateTime(now.year, now.month, now.day - _days), _days);
    final recorded = cur.whereType<Object>().length;

    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
      SegmentedButton<int>(
        segments: const [ButtonSegment(value: 7, label: Text('7 days')), ButtonSegment(value: 30, label: Text('30 days'))],
        selected: {_days},
        onSelectionChanged: (s) => setState(() => _days = s.first),
      ),
      const SizedBox(height: 10),
      Text('$recorded of $_days days have a record.', style: TextStyle(color: t.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      for (var i = 0; i < metrics.length; i++) _metric(context, i, today == null ? null : metrics[i].pick(today), sp.goalFor(metrics[i].label), cur, prev),
    ]);
  }

  Widget _stat(BuildContext context, String label, String value, {Color? color}) {
    final t = Theme.of(context);
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: tabular.copyWith(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
      ]),
    );
  }

  Widget _metric(BuildContext context, int i, int? todayVal, int goal, List<HealthRecord?> cur, List<HealthRecord?> prev) {
    final t = Theme.of(context);
    final m = metrics[i];
    final avg = Stats.average(cur, m.pick);
    final prevAvg = Stats.average(prev, m.pick);
    final best = Stats.best(cur, m.pick);
    final change = Stats.changePct(avg, prevAvg);
    final color = metricColor(t.colorScheme, i);
    final up = change != null && change >= 0;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconBadge(icon: m.icon, color: color, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text('${m.label} trend', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 10),
        Text(
          todayVal == null
              ? 'Today: no record'
              : 'Today: ${thousands(todayVal)} ${m.unit} (${Stats.goalPct(todayVal, goal).round()}% of goal)',
          style: tabular.copyWith(color: t.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        SimpleBarChart(
          values: [for (final r in cur) r == null ? null : m.pick(r)],
          labels: const [],
          color: color,
          unit: m.unit,
          title: '${m.label} over ${cur.length} days',
        ),
        const Divider(height: 28),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stat(context, 'Average', avg == null ? 'No data' : '${thousands(avg)} ${m.unit}'),
          _stat(context, 'Best day', best == null ? 'No data' : '${thousands(m.pick(best))} ${m.unit}'),
          _stat(
            context,
            'vs previous ${cur.length}d',
            change == null ? 'n/a' : '${up ? '+' : ''}${change.toStringAsFixed(1)}%',
            color: change == null ? null : (up ? metricColor(t.colorScheme, 0) : metricColor(t.colorScheme, 1)),
          ),
        ]),
        if (best != null) ...[
          const SizedBox(height: 8),
          Text('Best day was ${best.date}.', style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant)),
        ],
      ]),
    );
  }
}
