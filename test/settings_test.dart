import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/state/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults', () async {
    final sp = SettingsProvider(await SharedPreferences.getInstance());
    expect(sp.themeMode, ThemeMode.system);
    expect(sp.goalFor('Steps'), 10000);
  });

  test('theme and goals persist across a new provider instance', () async {
    final prefs = await SharedPreferences.getInstance();
    final a = SettingsProvider(prefs);
    await a.setTheme(ThemeMode.dark);
    await a.saveGoals({'Steps': 8000, 'Calories': 400, 'Water': 2000});
    final b = SettingsProvider(prefs);
    expect(b.themeMode, ThemeMode.dark);
    expect(b.goalFor('Steps'), 8000);
    await b.resetGoals();
    expect(SettingsProvider(prefs).goalFor('Steps'), 10000);
  });
}