import 'package:flutter/material.dart';
import 'widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget h(String s) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4), child: Text(s, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)));
    return Scaffold(
      appBar: AppBar(title: const Text('About / Help')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HealthMate - Find Your Balance', style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const Text('Version 1.0.0'),
            h('What it does'),
            const Text('Track daily steps, calories burned and water intake, and see your progress over time.'),
            h('How to use'),
            const Text('Tap + to add a record (one per date). Use Records to search, filter, edit or delete. '
                'Summary shows averages, best days and trends. Change goals and theme in Settings.'),
            h('Your data'),
            const Text('Records are stored on this device in a local SQLite database (sqflite). Nothing is sent anywhere.'),
            h('Disclaimer'),
            const Text('Goals are customisable targets, not medical advice.'),
          ]),
        ),
      ]),
    );
  }
}
