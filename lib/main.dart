import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database_helper.dart';
import 'data/health_repository.dart';
import 'state/records_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = HealthRepository(() => DatabaseHelper.instance.database);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RecordsProvider(repo)..load()),
    ],
    child: const HealthMateApp(),
  ));
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const Scaffold(
        body: Center(child: Text('HealthMate')),
      ),
    );
  }
}