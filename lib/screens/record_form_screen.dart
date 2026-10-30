import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/stats.dart';
import '../core/validators.dart';
import '../models/health_record.dart';
import '../state/records_provider.dart';
import 'widgets.dart';

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({super.key, this.recordId});
  final int? recordId;
  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _key = GlobalKey<FormState>();
  final _date = TextEditingController(text: fmtDate(DateTime.now()));
  final _steps = TextEditingController();
  final _cal = TextEditingController();
  final _water = TextEditingController();
  bool _loading = false, _saving = false, _missing = false;
  String? _error;
  HealthRecord? _conflict;

  bool get _editing => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void dispose() {
    _date.dispose();
    _steps.dispose();
    _cal.dispose();
    _water.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await context.read<RecordsProvider>().byId(widget.recordId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r == null) {
        _missing = true;
      } else {
        _date.text = r.date;
        _steps.text = '${r.steps}';
        _cal.text = '${r.calories}';
        _water.text = '${r.water}';
      }
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date.text = fmtDate(d));
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
      _conflict = null;
    });
    final p = context.read<RecordsProvider>();
    final clash = await p.byDate(_date.text);
    if (clash != null && clash.id != widget.recordId) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _conflict = clash;
      });
      return;
    }
    final err = await p.save(HealthRecord(
      id: widget.recordId,
      date: _date.text,
      steps: int.parse(_steps.text.trim()),
      calories: int.parse(_cal.text.trim()),
      water: int.parse(_water.text.trim()),
    ));
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _saving = false;
        _error = err;
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editing ? 'Record updated' : 'Record saved')));
    Navigator.pop(context);
  }

  Widget _num(TextEditingController c, String label, String help, String unit, int metric, String? Function(String?) v) {
    final color = metricColor(Theme.of(context).colorScheme, metric);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: v,
        decoration: InputDecoration(
          labelText: label,
          helperText: help,
          suffixText: unit,
          prefixIcon: Icon(metrics[metric].icon, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Health Record' : 'Add Health Record')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _missing
            ? EmptyState(
            icon: Icons.search_off,
            title: 'Record not found',
            message: 'This record may have been deleted.',
            action: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back')))
            : Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            Text(_editing ? 'Update your numbers' : 'How was your day?',
                style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('One record per day. All fields are required.', style: TextStyle(color: s.onSurfaceVariant)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _date,
              readOnly: true,
              onTap: _pickDate,
              validator: Validators.date,
              decoration: InputDecoration(
                labelText: 'Date',
                helperText: 'Tap to choose a date',
                prefixIcon: Icon(Icons.calendar_today_outlined, color: s.primary),
              ),
            ),
            const SizedBox(height: 16),
            _num(_steps, 'Steps walked', 'Whole number, 0 - ${Validators.maxSteps}', 'steps', 0, Validators.steps),
            _num(_cal, 'Calories burned', 'Whole number, 0 - ${Validators.maxCalories}', 'kcal', 1, Validators.calories),
            _num(_water, 'Water intake', 'Millilitres, 0 - ${Validators.maxWater}', 'ml', 2, Validators.water),
            if (_conflict != null)
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('A record for ${_conflict!.date} already exists.',
                      style: TextStyle(color: s.error, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => RecordFormScreen(recordId: _conflict!.id))),
                    child: const Text('Edit the existing record'),
                  ),
                ]),
              ),
            if (_error != null)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: s.error))),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_editing ? 'Save Changes' : 'Save Record'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
          ]),
        ),
      ),
    );
  }
}
