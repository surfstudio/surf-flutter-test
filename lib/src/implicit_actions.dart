import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

extension ImplicitActionsWidgetTester on WidgetTester {
  /// Метод для тапа на [finder] с встроенным ожиданием.
  /// Одно из самых важных implicit действий т.к. экономит очень много pump кода
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> implicitTap(Finder finder, {Duration? timeout}) async {
    await pumpUntilVisibleAmount(finder, 1, timeout: timeout);
    try {
      await tap(finder, warnIfMissed: false);
      await pump();
      // ignore: avoid_catching_errors
    } on StateError catch (e) {
      throw TestFailure(e.message);
    }
  }

  /// Метод для тапа на все виджеты которые соответствуют [finder].
  /// Например тапнуть на все чекбоксы согласия с политикой обработки данных
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> implicitTapAll(Finder finder, {Duration? timeout}) async {
    await pumpUntilVisible(finder, timeout: timeout);
    final list = widgetList(finder);
    for (final widget in list) {
      await implicitTap(find.byWidget(widget));
    }
  }

  /// Метод для ввода текста [text] в поле ввода [finder]
  /// Одно из самых важных implicit действий т.к. экономит очень много pump кода
  ///
  /// Вместо enterText использует низкоуровневые методы т.к. в версии 2.х поменяли
  /// логику каретки в этом методе и много где стало вводиться криво
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> implicitEnterText(Finder finder, String text, {Duration? timeout}) async {
    await pumpUntilVisibleAmount(finder, 1, timeout: timeout);
    try {
      // в обновлении добавили collapsed в TextEditingValue и от этого появились проблемы
      await showKeyboard(finder);
      testTextInput.updateEditingValue(TextEditingValue(text: text));
      await pump();
      // ignore: avoid_catching_errors
    } on StateError catch (e) {
      throw TestFailure(e.message);
    }
  }

  /// Метод для упрощенного скролла до виджета [finder] в направлении [moveStep]
  /// Указывать вью которую нужно свайпать не обязательно, т.к. находит ее сам используя TestScreen.scroll
  ///
  /// По сути является удобной оберткой над simpleDragUntilVisible, передавая в него параметры и найденный
  /// Finder виджета который будем скроллить
  ///
  /// [duration] отвечает за максимальную задержку между свайпами
  /// [maxIteration] задает максимальное количество свайпов
  /// [errorWidget] отвечает за проверку наличия нежелательных виджетов во время скролла, обычно
  /// им выступает ErrorWidget. Важно следить за тем какой ErrorWidget используется у вас на проекте,
  /// т.к. часто используется не наследование от flutter/widgets.ErrorWidget, а свой виджет с таким же названием
  Future<void> implicitScrollUntilVisible(
    Finder finder, {
    Offset moveStep = TestGestures.scrollDown,
    Duration? duration,
    int maxIteration = 50,
    Finder? scrollFinder,
    Finder? errorWidget,
  }) async {
    // не используем amount т.к. при использовании ancestor Finder'ов может быть более одного виджета
    await pumpUntilVisible(finder.changeSkipOffstage(), doThrow: false);
    scrollFinder ??= TestScreen().scroll;
    final scrollView = find.ancestor(of: finder.changeSkipOffstage(), matching: scrollFinder);
    await simpleDragUntilVisible(
      finder.hitTestable(),
      scrollView,
      moveStep,
      duration: duration,
      maxIteration: maxIteration,
      errorWidget: errorWidget,
    );
  }

  /// Метод для свайпа [view] в направлении [moveStep] пока [finder] не будет обнаружен.
  /// По сути является более универсальным скроллом чем scrollUntilVisible (требует Scrollable) и
  /// dragUntilVisible (использует Scrollable.ensureVisible которое часто ломается)
  ///
  /// [duration] отвечает за максимальную задержку между свайпами которая реализована через pumpUntilSettled
  /// [maxIteration] задает максимальное количество свайпов
  /// [errorWidget] отвечает за проверку наличия нежелательных виджетов во время скролла, обычно
  /// им выступает ErrorWidget. Важно следить за тем какой ErrorWidget используется у вас на проекте,
  /// т.к. часто используется не наследование от flutter/widgets.ErrorWidget, а свой виджет с таким же названием
  Future<void> simpleDragUntilVisible(
    Finder finder,
    Finder view,
    Offset moveStep, {
    Duration? duration,
    int maxIteration = 50,
    Finder? errorWidget,
  }) async {
    return TestAsyncUtils.guard<void>(() async {
      await pumpUntilVisible(view);
      bool condition() => finder.evaluate().isEmpty;
      for (var i = 0; i < maxIteration && safeEval(condition, true); i++) {
        await dragFrom(getCenter(view.first), moveStep);
        await pumpUntilSettled(timeout: duration);
        if (errorWidget != null && errorWidget.evaluate().isNotEmpty) {
          throw TestFailure('Error was encountered $errorWidget');
        }
      }
    });
  }

  /// Метод для тапа на текстовую кнопку внутри RichText виджета.
  Future<void> tapOnSpan(Finder finder, String text) async {
    try {
      await pumpUntilVisible(finder);
      final element = finder.evaluate().single;
      final paragraph = element.renderObject as RenderParagraph;
      paragraph.text.visitChildren((span) {
        if (span is TextSpan) {
          if (span.text != text) return true;
          (span.recognizer as TapGestureRecognizer).onTap?.call();
        }
        return false;
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // ignore: only_throw_errors, avoid-throw-in-catch-block
      throw TestFailure('$e');
    }
  }

  /// Функция для проверки текста виджета [Text].
  Future<void> checkDataOfText(Finder finder, String text) async {
    await pumpUntilVisible(finder);
    final textWidget = widget<Text>(finder);
    expect(textWidget.data?.replaceAll('\u{00A0}', ' '), text);
  }

  /// Функция для проверки текста виджета [TextField].
  Future<void> checkTextOfTexField(Finder finder, String text) async {
    await pumpUntilVisible(finder);
    final textWidget = widget<TextField>(finder);
    expect(textWidget.controller?.text, text);
  }

  /// Функция для скрытия экранной клавиатуры.
  Future<void> hideKeyboard() async {
    return TestAsyncUtils.guard<void>(() async {
      FocusManager.instance.primaryFocus?.unfocus();
      await pump();
    });
  }

  /// Функция, которая делает PTR.
  Future<void> makePtr(Finder finder) async {
    await drag(
      finder,
      TestGestures.flickDown,
    );
    await pumpForDuration(const Duration(milliseconds: 500));
  }


}
