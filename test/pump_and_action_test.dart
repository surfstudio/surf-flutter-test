import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

final testScreen = TestScreen();

void main() {
  final buttonFinder = find.widgetWithText(ElevatedButton, 'Show snackbar');
  final buttonFinder2 = find.widgetWithText(ElevatedButton, 'Show snackbar2');
  final snackFinder = find.widgetWithText(SnackBar, 'Yay! A SnackBar!');
  final snackFinder2 = find.widgetWithText(SnackBar, 'Yay! A SnackBar number two!');
  group('pumps tests', () {
    testWidgets('check usual pump is not working', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(snackFinder, findsNothing);
      // нужно подождать пока pending timer закончится
      await tester.binding.delayed(const Duration(milliseconds: 200));
    });
    testWidgets('pump for duration', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpForDuration(const Duration(milliseconds: 200));
      expect(snackFinder, findsOneWidget);
    });
    testWidgets('pump until settled', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpUntilSettled(timeout: const Duration(milliseconds: 1000));
      expect(snackFinder, findsOneWidget);
    });
    testWidgets('pump until condition', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpUntilCondition(() => snackFinder.evaluate().isNotEmpty);
      expect(snackFinder, findsOneWidget);
    });
    testWidgets('pump until visible', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpUntilVisible(snackFinder);
      expect(snackFinder, findsOneWidget);
    });
    testWidgets('pump until visible any', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder2);
      await tester.pumpUntilVisibleAny([snackFinder, snackFinder2]);
      expect(snackFinder2, findsOneWidget);
    });
    testWidgets('pump until not visible', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpUntilVisible(snackFinder);
      await tester.pumpUntilNotVisible(snackFinder);
      expect(snackFinder, findsNothing);
    });
    testWidgets('pump until not visible any', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder2);
      await tester.pumpUntilVisibleAny([snackFinder, snackFinder2]);
      await tester.pumpUntilNotVisibleAny([snackFinder, snackFinder2]);
      expect([snackFinder, snackFinder2].any((f) => f.evaluate().isEmpty), true);
    });
    testWidgets('pump until visible amount', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.tap(buttonFinder);
      await tester.pumpUntilVisibleAmount(snackFinder, 1);
      expect(snackFinder, findsOneWidget);
    });
  });
  group('actions tests', () {
    testWidgets('implicit tap', (tester) async {
      await tester.pumpWidget(const _App(_SnackPage()));
      await tester.implicitTap(buttonFinder);
      await tester.pumpUntilVisible(snackFinder);
      expect(snackFinder, findsOneWidget);
    });
    testWidgets('implicit tap all', (tester) async {
      await tester.pumpWidget(const _App(_CheckboxPage()));
      final finder = find.byType(Checkbox);
      await tester.implicitTapAll(finder);
      expect(finder, findsNWidgets(2));
    });
    testWidgets('implicit enter text', (tester) async {
      await tester.pumpWidget(const _App(_TextFieldPage()));
      final finder = find.byType(TextField);
      await tester.implicitEnterText(finder, 'test');
      expect(tester.widget<TextField>(finder).controller?.text, 'test');
    });
    testWidgets('implicit scroll', (tester) async {
      await tester.pumpWidget(const _App(_ScrollPage()));
      final finder = find.text('Text3');
      expect(finder, findsNothing);
      await tester.implicitScrollUntilVisible(finder);
      expect(finder, findsOneWidget);
    });
    testWidgets('simple drag', (tester) async {
      await tester.pumpWidget(const _App(_ScrollPage()));
      final finder = find.text('Text3');
      expect(finder, findsNothing);
      await tester.simpleDragUntilVisible(
        finder,
        find.byType(ListView),
        TestGestures.scrollDown,
      );
      expect(finder, findsOneWidget);
    });
  });
}

class _App extends StatelessWidget {
  final Widget child;

  const _App(this.child);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

class _SnackPage extends StatelessWidget {
  const _SnackPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 200), () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Yay! A SnackBar!'),
                ));
              });
            },
            child: const Text('Show snackbar'),
          ),
          ElevatedButton(
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 200), () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Yay! A SnackBar number two!'),
                ));
              });
            },
            child: const Text('Show snackbar2'),
          ),
        ],
      ),
    );
  }
}

class _CheckboxPage extends StatelessWidget {
  const _CheckboxPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          CheckBoxWidget(key: Key('check 1')),
          CheckBoxWidget(key: Key('check 2')),
        ],
      ),
    );
  }
}

class CheckBoxWidget extends StatefulWidget {
  const CheckBoxWidget({Key? key}) : super(key: key);

  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}

class _TextFieldPage extends StatelessWidget {
  const _TextFieldPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        controller: TextEditingController(),
      ),
    );
  }
}

class _ScrollPage extends StatelessWidget {
  const _ScrollPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(
          height: 300,
          child: Text('Text1'),
        ),
        SizedBox(
          height: 300,
          child: Text('Text2'),
        ),
        SizedBox(
          height: 300,
          child: Text('Text3'),
        ),
      ],
    );
  }
}
