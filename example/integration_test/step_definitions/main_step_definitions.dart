import 'package:surf_flutter_test/surf_flutter_test.dart';

import '../../test_screen/test_screen_library.dart';

final mainStepDefinitions = [
  testerWhen<ContextualWorld>(
    RegExp(r'Я перехожу к редактированию профиля$'),
    (context, tester) async {
      await tester.implicitTap(mainTestScreen.editProfileBtn);
    },
  ),
];
