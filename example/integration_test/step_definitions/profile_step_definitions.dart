import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';
import '../../test_screen/screens/profile_test_screen.dart';
import '../../test_screen/test_screen_library.dart';

final profileStepDefinitions = [
  testerWhen<ContextualWorld>(
    RegExp(r'Я перехожу далее$'),
    (context, tester) async {
      await tester.implicitTap(profileTestScreen.nextButton);
    },
  ),
  testerWhen<ContextualWorld>(
    RegExp(r'Я сохраняю профиль$'),
    (context, tester) async {
      await tester.implicitTap(profileTestScreen.saveButton);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я указываю фамилию {string}$'),
    (surname, context, tester) async {
      await tester.implicitEnterText(profileTestScreen.surnameField, surname);
      context.world.setContext(ProfileTestParams.surname, surname);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я указываю имя {string}$'),
    (firstName, context, tester) async {
      await tester.implicitEnterText(profileTestScreen.firstNameField, firstName);
      context.world.setContext(ProfileTestParams.firstName, firstName);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я указываю отчество {string}$'),
    (secondName, context, tester) async {
      await tester.implicitEnterText(profileTestScreen.secondNameField, secondName);
      context.world.setContext(ProfileTestParams.secondName, secondName);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я указываю дату рождения {string}$'),
    (birthdate, context, tester) async {
      final finder = profileTestScreen.birthdayField;
      await tester.pumpUntilVisible(finder);
      tester.widget<TextField>(finder).controller?.text = birthdate;
      await tester.pump();
      context.world.setContext(ProfileTestParams.birthdate, birthdate);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я выбираю город {string}$'),
    (city, context, tester) async {
      final finder = profileTestScreen.cityField;
      await tester.pumpUntilVisible(finder);
      tester.widget<TextField>(finder).controller?.text = city;
      await tester.pump();
      context.world.setContext(ProfileTestParams.city, city);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я выбираю {string} из интересов$'),
    (interest, context, tester) async {
      final finder = profileTestScreen.interestCheckbox(interest);
      await tester.implicitScrollUntilVisible(finder);
      // жмем на выключенные только
      if (!(tester.widget<Checkbox>(finder).value ?? false)) {
        await tester.implicitTap(finder);
      }
      context.world.setContext(ProfileTestParams.interest, interest);
    },
  ),
  testerWhen1<String, ContextualWorld>(
    RegExp(r'Я заполняю заметку о себе {string}$'),
    (aboutMe, context, tester) async {
      await tester.implicitEnterText(profileTestScreen.aboutMeField, aboutMe);
      context.world.setContext(ProfileTestParams.aboutMe, aboutMe);
    },
  ),
  testerThen<ContextualWorld>(
    RegExp(r'Я вижу заполненные поля ФИО$'),
    (context, tester) async {
      await tester.pumpUntilVisible(profileTestScreen.firstNameField);
      final name = tester.widget<TextField>(profileTestScreen.firstNameField).controller?.text;
      final surname = tester.widget<TextField>(profileTestScreen.surnameField).controller?.text;
      final secondName =
          tester.widget<TextField>(profileTestScreen.secondNameField).controller?.text;
      expect(name, context.world.getContext<String>(ProfileTestParams.firstName));
      expect(surname, context.world.getContext<String>(ProfileTestParams.surname));
      expect(secondName, context.world.getContext<String>(ProfileTestParams.secondName));
    },
  ),
  testerThen<ContextualWorld>(
    RegExp(r'Я вижу заполненное поле даты рождения$'),
    (context, tester) async {
      await tester.pumpUntilVisible(profileTestScreen.birthdayField);
      final birthdate = tester.widget<TextField>(profileTestScreen.birthdayField).controller?.text;
      expect(birthdate, context.world.getContext<String>(ProfileTestParams.birthdate));
    },
  ),
  testerThen<ContextualWorld>(
    RegExp(r'Я вижу заполненное поле города$'),
    (context, tester) async {
      await tester.pumpUntilVisible(profileTestScreen.cityField);
      final city = tester.widget<TextField>(profileTestScreen.cityField).controller?.text;
      expect(city, context.world.getContext<String>(ProfileTestParams.city));
    },
  ),
  testerThen<ContextualWorld>(
    RegExp(r'Я вижу выбранный интерес$'),
    (context, tester) async {
      final interest = context.world.getContext<String>(ProfileTestParams.interest);
      await tester.implicitScrollUntilVisible(profileTestScreen.interestCheckbox(interest));
      final value = tester.widget<Checkbox>(profileTestScreen.interestCheckbox(interest)).value;
      expect(value, isTrue);
    },
  ),
  testerThen<ContextualWorld>(
    RegExp(r'Я вижу заполненное поле заметки о себе$'),
    (context, tester) async {
      await tester.pumpUntilVisible(profileTestScreen.aboutMeField);
      final aboutMe = tester.widget<TextField>(profileTestScreen.aboutMeField).controller?.text;
      expect(aboutMe, context.world.getContext<String>(ProfileTestParams.aboutMe));
    },
  ),
];
