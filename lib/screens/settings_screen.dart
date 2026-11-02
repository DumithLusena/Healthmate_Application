import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../state/settings_provider.dart';
import 'widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  static const _max = {'Steps': Validators.maxSteps, 'Calories': Validators.maxCalories, 'Water': Validators.maxWater};
  static const _unit = {'Steps': 'steps', 'Calories': 'kcal', 'Water': 'ml'};
  static const _metricIndex = {'Steps': 0, 'Calories': 1, 'Water': 2};

  @override
  void initState() {
    super.initState();
    final sp = context.read<SettingsProvider>();
    _c = {for (final k in SettingsProvider.defaults.keys) k: TextEditingController(text: '${sp.goalFor(k)}')};
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    await context.read<SettingsProvider>().saveGoals({for (final e in _c.entries) e.key: int.parse(e.value.text.trim())});
    if (mounted) _snack('Goals saved');
  }

  Future<void> _reset() async {
    final sp = context.read<SettingsProvider>();
    await sp.resetGoals();
    for (final e in _c.entries) {
      e.value.text = '${sp.goalFor(e.key)}';
    }
    if (mounted) _snack('Goals reset to defaults');
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final t = Theme.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
      const SectionTitle('Appearance'),
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
        ],
        selected: {sp.themeMode},
        onSelectionChanged: (s) => sp.setTheme(s.first),
      ),
      const SizedBox(height: 12),
      const SectionTitle('Daily goals'),
      Text('Goals are customisable targets, not medical advice.', style: TextStyle(color: t.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      Form(
        key: _key,
        child: Column(children: [
          for (final e in _c.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: e.value,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final err = Validators.count(v, label: '${e.key} goal', max: _max[e.key]!);
                  return err ?? (int.parse(v!.trim()) == 0 ? 'Goal must be greater than 0' : null);
                },
                decoration: InputDecoration(
                  labelText: '${e.key} goal',
                  suffixText: _unit[e.key],
                  prefixIcon: Icon(metrics[_metricIndex[e.key]!].icon, color: metricColor(t.colorScheme, _metricIndex[e.key]!)),
                ),
              ),
            ),
          Row(children: [
            Expanded(child: FilledButton(onPressed: _save, child: const Text('Save goals'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: _reset, child: const Text('Reset'))),
          ]),
        ]),
      ),
    ]);
  }
}