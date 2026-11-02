import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/screens/widgets.dart';

void main() {
  testWidgets('MetricCard shows value, unit and goal progress', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MetricCard(index: 0, value: 5000, goal: 10000)),
    ));
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.textContaining('5,000'), findsOneWidget);
  });

  testWidgets('MetricCard shows placeholder when there is no record', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MetricCard(index: 2, value: null, goal: 2500)),
    ));
    expect(find.text('No record'), findsOneWidget);
  });
}
