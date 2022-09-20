import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

final testScreen = TestScreen();

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
      expect(testScreen.scroll, findsNWidgets(3));
    });
    testWidgets('finds close btn', (tester) async {
      await tester.pumpWidget(_boilerplate(Column(
        children: const [
          Icon(Icons.close),
          Icon(Icons.cancel_rounded),
        ],
      )));
      expect(testScreen.closeBtn, findsNWidgets(2));
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
      expect(testScreen.textFieldByLabel('test'), findsNWidgets(2));
      expect(testScreen.textFieldByLabelPartial('est'), findsNWidgets(2));
    });
    testWidgets('change skip offstage', (tester) async {
      await tester.pumpWidget(_boilerplate(
        const Offstage(child: Text('test')),
      ));
      final finder = testScreen.textPartial('test');
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
