import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../state/records_provider.dart';
import 'widgets.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  Future<void> _delete(BuildContext context, RecordsProvider p, HealthRecord r) async {
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Record deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecordsProvider>();
    final s = Theme.of(context).colorScheme;
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.records.isEmpty) {
      return const EmptyState(
        icon: Icons.list_alt,
        title: 'No records yet',
        message: 'Tap "Add record" to log your first day.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: p.records.length,
      itemBuilder: (_, i) {
        final r = p.records[i];
        return RecordTile(
          record: r,
          trailing: IconButton(
            tooltip: 'Delete ${r.date}',
            icon: Icon(Icons.delete_outline, color: s.error),
            onPressed: () => _delete(context, p, r),
          ),
        );
      },
    );
  }
}