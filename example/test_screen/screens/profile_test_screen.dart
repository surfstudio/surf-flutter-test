import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

abstract class ProfileTestParams {
  static const String firstName = 'first_name';
  static const String surname = 'surname';
  static const String secondName = 'second_name';
  static const String birthdate = 'birthday';
  static const String city = 'city';
  static const String interest = 'interest';
  static const String aboutMe = 'about_me';
}

class ProfileTestScreen extends TestScreen {
  /// поле Surname на экране персональных данных
  Finder get surnameField => textFieldByLabel('Surname');

  /// поле Name на экране персональных данных
  Finder get firstNameField => textFieldByLabel('Name');

  /// поле Surname на экране персональных данных
  Finder get secondNameField => textFieldByLabel('SecondName');

  /// поле Birthday на экране персональных данных
  Finder get birthdayField => textFieldByLabel('Birthday');

  /// поле Place of residence на экране выбора города
  Finder get cityField => textFieldByLabel('Place of residence');

  /// поле About me на экране заметки о себе
  Finder get aboutMeField => textFieldByLabelPartial('about yourself');

  /// чекбокс интереса соответствующий тексту [t]
  Finder interestCheckbox(String t) => find.descendant(
        of: find.ancestor(of: find.text(t), matching: find.byType(Row)),
        matching: find.byType(Checkbox),
      );

  /// описание интереса для проверки выбранных
  Finder interest = find.descendant(
    of: find.ancestor(of: find.byType(Checkbox), matching: find.byType(Row)),
    matching: find.byType(Text),
  );

  /// кнопка далее на экранах ввода данных
  Finder nextButton = find.widgetWithIcon(ElevatedButton, Icons.navigate_next);

  /// кнопка сохранить на последнем экране
  Finder saveButton = find.widgetWithText(ElevatedButton, 'Save');
}
