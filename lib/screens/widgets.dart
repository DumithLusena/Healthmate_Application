import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../models/health_record.dart';

class Metric {
  const Metric(this.label, this.unit, this.icon, this.pick);
  final String label, unit;
  final IconData icon;
  final int Function(HealthRecord) pick;
}

int _steps(HealthRecord r) => r.steps;
int _cal(HealthRecord r) => r.calories;
int _water(HealthRecord r) => r.water;

const metrics = [
  Metric('Steps', 'steps', Icons.directions_walk, _steps),
  Metric('Calories', 'kcal', Icons.local_fire_department, _cal),
  Metric('Water', 'ml', Icons.water_drop, _water),
];

Color metricColor(ColorScheme s, int i) {
  final dark = s.brightness == Brightness.dark;
  return [
    dark ? const Color(0xFF4BD39B) : const Color(0xFF1B9E6B),
    dark ? const Color(0xFFFF7A7F) : const Color(0xFFDC3545),
    dark ? const Color(0xFF6FB7FF) : const Color(0xFF1F6FDB),
  ][i];
}

const tabular = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

String thousands(num n) => n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);
    final content = Padding(padding: padding, child: child);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 5))],
      ),
      child: Material(
        color: s.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: s.outline)),
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Row(children: [
      Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      if (trailing != null) trailing!,
    ]),
  );
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 44});
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color.withAlpha(36), borderRadius: BorderRadius.circular(size * 0.32)),
    child: Icon(icon, color: color, size: size * 0.5),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: t.colorScheme.primary.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, size: 42, color: t.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: t.colorScheme.onSurfaceVariant)),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ]),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.index, required this.value, required this.goal});
  final int index;
  final int? value; // null = no record today
  final int goal;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final m = metrics[index];
    final color = metricColor(s, index);
    final pct = value == null || goal <= 0 ? 0.0 : value! / goal;
    return Panel(
      child: Semantics(
        label: '${m.label}: ${value == null ? 'no record today' : '${thousands(value!)} ${m.unit}'}, '
            '${(pct * 100).round()} percent of goal ${thousands(goal)}',
        child: Row(children: [
          IconBadge(icon: m.icon, color: color, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m.label, style: TextStyle(color: s.onSurfaceVariant, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(value == null ? 'No record' : '${(pct * 100).round()}%',
                    style: tabular.copyWith(color: color, fontWeight: FontWeight.w800)),
              ]),
              Text.rich(TextSpan(children: [
                TextSpan(text: value == null ? '--' : thousands(value!), style: tabular.copyWith(fontSize: 28, fontWeight: FontWeight.w800)),
                TextSpan(text: ' ${m.unit}', style: TextStyle(fontSize: 13, color: s.onSurfaceVariant)),
              ])),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  color: color,
                  backgroundColor: color.withAlpha(36),
                ),
              ),
              const SizedBox(height: 4),
              Text('Goal: ${thousands(goal)} ${m.unit}', style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(text, style: tabular.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, this.onTap, this.trailing});
  final HealthRecord record;
  final VoidCallback? onTap;
  final Widget? trailing;

  static const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final d = DateTime.tryParse(record.date);
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: s.primary.withAlpha(30), borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(d == null ? '--' : '${d.day}', style: tabular.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: s.primary)),
            Text(d == null ? '' : _months[d.month - 1], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: s.primary)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d == null ? record.date : '${_days[d.weekday - 1]}  ${record.date}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              StatChip(icon: metrics[0].icon, text: thousands(record.steps), color: metricColor(s, 0)),
              StatChip(icon: metrics[1].icon, text: '${record.calories} kcal', color: metricColor(s, 1)),
              StatChip(icon: metrics[2].icon, text: '${thousands(record.water)} ml', color: metricColor(s, 2)),
            ]),
          ]),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart(
      {super.key,
        required this.values,
        required this.labels,
        required this.color,
        required this.unit,
        required this.title,
        this.highlightLast = false});
  final List<int?> values;
  final List<String> labels;
  final Color color;
  final String unit, title;
  final bool highlightLast;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final maxV = values.whereType<int>().fold<int>(0, (a, b) => b > a ? b : a);
    final recorded = values.whereType<int>().length;
    return Semantics(
      label: '$title chart, $recorded of ${values.length} days recorded',
      child: SizedBox(
        height: 140,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: values[i] == null
                    ? '${labels.isEmpty ? 'Day ${i + 1}' : labels[i]}: no record'
                    : '${labels.isEmpty ? 'Day ${i + 1}' : labels[i]}: ${thousands(values[i]!)} $unit',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      height: values[i] == null ? 4 : (maxV == 0 ? 4 : 6 + values[i]! / maxV * 98),
                      decoration: BoxDecoration(
                        color: values[i] == null
                            ? s.outline
                            : (highlightLast && i != values.length - 1 ? color.withAlpha(110) : color),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    if (labels.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(labels[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: highlightLast && i == values.length - 1 ? FontWeight.w800 : FontWeight.w500,
                              color: s.onSurfaceVariant)),
                    ],
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
