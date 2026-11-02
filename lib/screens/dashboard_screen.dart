import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/stats.dart';
import '../core/theme.dart';
import '../state/records_provider.dart';
import '../state/settings_provider.dart';
import 'record_form_screen.dart';
import 'widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RecordsProvider>();
    final sp = context.watch<SettingsProvider>();
    final t = Theme.of(context);
    final now = DateTime.now();
    if (rp.loading) return const Center(child: CircularProgressIndicator());
    if (rp.error != null) {
      return EmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          message: rp.error!,
          action: FilledButton(onPressed: rp.load, child: const Text('Retry')));
    }
    final today = rp.records.where((r) => r.date == fmtDate(now)).firstOrNull;
    final week = Stats.window(rp.records, now, 7);
    final greeting = now.hour < 12 ? 'Good morning' : (now.hour < 17 ? 'Good afternoon' : 'Good evening');
    void add() => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordFormScreen()));
    Future<void> water(int ml) async {
      final err = await context.read<RecordsProvider>().addWaterToday(ml);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? '+$ml ml water added')));
      }
    }

    var overall = 0.0;
    if (today != null) {
      for (var i = 0; i < metrics.length; i++) {
        final pct = Stats.goalPct(metrics[i].pick(today), sp.goalFor(metrics[i].label)) / 100;
        overall += pct.clamp(0.0, 1.0).toDouble() / metrics.length;
      }
    }
    final name = sp.userName;

    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 96), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? greeting : '$greeting,',
                style: TextStyle(color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            Text(name.isEmpty ? 'Welcome back' : name,
                style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ]),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: t.colorScheme.primary.withAlpha(36),
          child: name.isEmpty
              ? Icon(Icons.person, color: t.colorScheme.primary)
              : Text(String.fromCharCode(name.runes.first).toUpperCase(),
              style: TextStyle(color: t.colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 18)),
        ),
      ]),
      const SizedBox(height: 16),

      if (rp.records.isEmpty)
        Panel(
          child: Column(children: [
            const SizedBox(height: 8),
            Icon(Icons.spa_outlined, size: 48, color: t.colorScheme.primary),
            const SizedBox(height: 8),
            Text('No records yet', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Add your first day of steps, calories and water.',
                textAlign: TextAlign.center),
          ]),
        )
      else ...[
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.brand, AppTheme.brandDeep],
            ),
            boxShadow: const [BoxShadow(color: Color(0x330B6E8A), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TODAY', style: TextStyle(color: Colors.white.withAlpha(200), fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 12)),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, d MMMM').format(now),
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  today == null
                      ? 'No record for today yet. Add one to start your day.'
                      : overall >= 1
                      ? 'All daily goals reached. Great job!'
                      : overall >= 0.5
                      ? 'Over halfway there. Keep going!'
                      : 'A good start. Every step counts.',
                  style: TextStyle(color: Colors.white.withAlpha(225), height: 1.35),
                ),
                if (today == null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: add,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.brandDeep,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Add today', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 92,
              height: 92,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: overall,
                    strokeWidth: 9,
                    color: Colors.white,
                    backgroundColor: Colors.white.withAlpha(60),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(overall * 100).round()}%',
                      style: tabular.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('of goals', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
                ]),
              ]),
            ),
          ]),
        ),

        const SectionTitle("Today's activity"),
        for (var i = 0; i < metrics.length; i++)
          MetricCard(index: i, value: today == null ? null : metrics[i].pick(today), goal: sp.goalFor(metrics[i].label)),

        Panel(
          child: Row(children: [
            IconBadge(icon: Icons.water_drop, color: metricColor(t.colorScheme, 2), size: 44),
            const SizedBox(width: 12),
            const Expanded(child: Text('Drink some water?', style: TextStyle(fontWeight: FontWeight.w700))),
            ActionChip(label: const Text('+250 ml'), onPressed: () => water(250)),
            const SizedBox(width: 6),
            ActionChip(label: const Text('+500 ml'), onPressed: () => water(500)),
          ]),
        ),

        const SectionTitle('Last 7 days'),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(metrics[0].icon, size: 18, color: metricColor(t.colorScheme, 0)),
              const SizedBox(width: 6),
              const Text('Steps', style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 14),
            SimpleBarChart(
              values: [for (final r in week) r?.steps],
              labels: [for (var i = 6; i >= 0; i--) DateFormat('E').format(DateTime(now.year, now.month, now.day - i)).substring(0, 1)],
              color: metricColor(t.colorScheme, 0),
              unit: 'steps',
              title: 'Steps over the last 7 days',
              highlightLast: true,
            ),
            const SizedBox(height: 6),
            Text('Grey bars mean no record for that day.', style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant)),
          ]),
        ),

        SectionTitle('Recent records', trailing: TextButton(onPressed: onViewAll, child: const Text('View all'))),
        for (final r in rp.records.take(3))
          RecordTile(
            record: r,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecordFormScreen(recordId: r.id))),
          ),
      ],
    ]);
  }
}
