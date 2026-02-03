import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Radio Player', key: const Key('title'))),
        ),
      ),
    );
    expect(find.byKey(const Key('title')), findsOneWidget);
  });
}
