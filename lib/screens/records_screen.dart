import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/stats.dart';
import '../models/health_record.dart';
import '../state/records_provider.dart';
import 'record_form_screen.dart';
import 'widgets.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickRange(RecordsProvider p) async {
    final r = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (r != null) p.setQuery(p.query.copyWith(from: fmtDate(r.start), to: fmtDate(r.end)));
  }

  Future<void> _delete(RecordsProvider p, HealthRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Delete the record for ${r.date} (${thousands(r.steps)} steps, ${r.calories} kcal, ${thousands(r.water)} ml)? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44), backgroundColor: Theme.of(c).colorScheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final err = await p.remove(r.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Record deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecordsProvider>();
    final q = p.query;
    final s = Theme.of(context).colorScheme;
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.records.isEmpty && !q.isFiltered) {
      return const EmptyState(
        icon: Icons.list_alt,
        title: 'No records yet',
        message: 'Tap "Add record" to log your first day.',
      );
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(children: [
          TextField(
            controller: _search,
            onChanged: (v) => p.setQuery(q.copyWith(search: v.trim())),
            decoration: InputDecoration(
              hintText: 'Search by date (YYYY-MM-DD)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: q.search.isEmpty
                  ? null
                  : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _search.clear();
                  p.setQuery(q.copyWith(search: ''));
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                onPressed: () => _pickRange(p),
                icon: const Icon(Icons.date_range, size: 20),
                label: Text(q.from == null ? 'Date range' : '${q.from} to ${q.to}', overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.only(left: 12),
              height: 44,
              decoration: BoxDecoration(
                color: s.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: s.outline),
              ),
              child: Row(children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: q.sortBy,
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(value: 'steps', child: Text('Steps')),
                      DropdownMenuItem(value: 'calories', child: Text('Calories')),
                      DropdownMenuItem(value: 'water', child: Text('Water')),
                    ],
                    onChanged: (v) => p.setQuery(q.copyWith(sortBy: v)),
                  ),
                ),
                IconButton(
                  tooltip: q.desc ? 'Sorted high to low' : 'Sorted low to high',
                  icon: Icon(q.desc ? Icons.arrow_downward : Icons.arrow_upward, size: 20),
                  onPressed: () => p.setQuery(q.copyWith(desc: !q.desc)),
                ),
              ]),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(
                child: Text('${p.visible.length} record${p.visible.length == 1 ? '' : 's'}',
                    style: TextStyle(color: s.onSurfaceVariant, fontWeight: FontWeight.w600)),
              ),
              if (q.isFiltered)
                TextButton(
                  onPressed: () {
                    _search.clear();
                    p.setQuery(q.copyWith(search: '', clearRange: true));
                  },
                  child: const Text('Clear filters'),
                ),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: p.visible.isEmpty
            ? const EmptyState(icon: Icons.filter_alt_off, title: 'No matching records', message: 'Try a different search or clear the filters.')
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          itemCount: p.visible.length,
          itemBuilder: (_, i) {
            final r = p.visible[i];
            return RecordTile(
              record: r,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecordFormScreen(recordId: r.id))),
              trailing: IconButton(
                tooltip: 'Delete ${r.date}',
                icon: Icon(Icons.delete_outline, color: s.error),
                onPressed: () => _delete(p, r),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
