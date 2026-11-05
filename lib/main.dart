import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'data/database_helper.dart';
import 'data/health_repository.dart';
import 'screens/dashboard_screen.dart';
import 'screens/record_form_screen.dart';
import 'screens/records_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/records_provider.dart';
import 'state/settings_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repo = HealthRepository(() => DatabaseHelper.instance.database);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
      ChangeNotifierProvider(create: (_) => RecordsProvider(repo)..load()),
    ],
    child: const HealthMateApp(),
  ));
}

class HealthMateApp extends StatefulWidget {
  const HealthMateApp({super.key});
  @override
  State<HealthMateApp> createState() => _HealthMateAppState();
}

class _HealthMateAppState extends State<HealthMateApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final Widget home = !_splashDone
        ? SplashScreen(
      key: const ValueKey('splash'),
      onFinished: () => setState(() => _splashDone = true),
    )
        : (sp.onboarded
        ? const Shell(key: ValueKey('shell'))
        : const WelcomeScreen(key: ValueKey('welcome')));

    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: sp.themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: home,
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  static const _titles = ['HealthMate', 'Health Records', 'Daily Summary', 'Settings'];

  void _add() => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordFormScreen()));

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final pages = [
      DashboardScreen(onViewAll: () => setState(() => _i = 1)),
      const RecordsScreen(),
      const SummaryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: _i == 0
            ? Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.favorite, color: s.primary, size: 22),
          const SizedBox(width: 8),
          Text(_titles[0]),
        ])
            : Text(_titles[_i]),
      ),
      body: SafeArea(child: pages[_i]),
      floatingActionButton: (_i == 0 || _i == 1)
          ? FloatingActionButton.extended(
        tooltip: 'Add health record',
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add record'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Records'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
