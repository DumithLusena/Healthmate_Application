import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._p) {
    themeMode = ThemeMode.values.firstWhere((m) => m.name == _p.getString('theme'), orElse: () => ThemeMode.system);
    goals = {for (final e in defaults.entries) e.key: _p.getInt('goal_${e.key}') ?? e.value};
    userName = _p.getString('user_name') ?? '';
    onboarded = _p.getBool('onboarded') ?? false;
  }

  static const defaults = {'Steps': 10000, 'Calories': 500, 'Water': 2500};
  final SharedPreferences _p;
  late ThemeMode themeMode;
  late Map<String, int> goals;
  late String userName;
  late bool onboarded;

  int goalFor(String label) => goals[label] ?? defaults[label]!;

  Future<void> setTheme(ThemeMode m) async {
    themeMode = m;
    notifyListeners();
    await _p.setString('theme', m.name);
  }

  Future<void> setName(String name) async {
    userName = name.trim();
    notifyListeners();
    await _p.setString('user_name', userName);
  }

  Future<void> completeOnboarding(String name) async {
    userName = name.trim();
    onboarded = true;
    notifyListeners();
    await _p.setString('user_name', userName);
    await _p.setBool('onboarded', true);
  }

  Future<void> saveGoals(Map<String, int> g) async {
    goals = {...g};
    for (final e in g.entries) {
      await _p.setInt('goal_${e.key}', e.value);
    }
    notifyListeners();
  }

  Future<void> resetGoals() async {
    for (final k in defaults.keys) {
      await _p.remove('goal_$k');
    }
    goals = {...defaults};
    notifyListeners();
  }
}
