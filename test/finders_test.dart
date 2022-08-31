import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

final baseTestScreen = BaseTestScreen();

void main() {
  group('finder tests', () {
    testWidgets('finds scroll', (tester) async {
      await tester.pumpWidget(_boilerplate(Column(
        children: [
          const SizedBox(
            height: 100,
            child: CustomScrollView(),
          ),
          const SizedBox(
            height: 100,
            child: SingleChildScrollView(),
          ),
          SizedBox(
            height: 100,
            child: ListView(),
          ),
        ],
      )));
      expect(baseTestScreen.scroll, findsNWidgets(3));
    });
    testWidgets('finds partial text', (tester) async {
      await tester.pumpWidget(_boilerplate(
        const Text('Some_long_text'),
      ));
      expect(baseTestScreen.textPartial('text'), findsOneWidget);
    });
    testWidgets('finds close btn', (tester) async {
      await tester.pumpWidget(_boilerplate(Column(
        children: const [
          Icon(Icons.close),
          Icon(Icons.cancel_rounded),
        ],
      )));
      expect(baseTestScreen.closeBtn, findsNWidgets(2));
    });
    testWidgets('finds text field by label or hint', (tester) async {
      await tester.pumpWidget(_boilerplate(Column(
        children: const [
          TextField(
            decoration: InputDecoration(labelText: 'test'),
          ),
          TextField(
            decoration: InputDecoration(hintText: 'test'),
          ),
        ],
      )));
      expect(baseTestScreen.textFieldByLabel('test'), findsNWidgets(2));
      expect(baseTestScreen.textFieldByLabelPartial('est'), findsNWidgets(2));
    });
    testWidgets('change skip offstage', (tester) async {
      await tester.pumpWidget(_boilerplate(
        const Offstage(child: Text('test')),
      ));
      final finder = baseTestScreen.textPartial('test');
      expect(finder, findsNothing);
      expect(finder.changeSkipOffstage(), findsOneWidget);
    });
  });
}

//ignore: avoid-returning-widgets
Widget _boilerplate(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
