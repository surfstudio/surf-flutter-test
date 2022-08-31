import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

extension ImplicitActionsWidgetTester on WidgetTester {
  /// Функция чтобы убрать избыточные pump из кода шагов при тапах
  Future<void> implicitTap(Finder finder, {Duration? timeout}) async {
    await pumpUntilVisibleAmount(finder, 1, timeout: timeout);
    try {
      await tap(finder, warnIfMissed: false);
      await pump();
    }
    // ignore: avoid_catching_errors
    on StateError catch (e) {
      // ignore: only_throw_errors
      throw TestFailure(e.message);
    }
  }

  /// Функция чтобы тапать на все виджеты если finder возвращает несколько виджетов
  Future<void> implicitTapAll(Finder finder, {Duration? timeout}) async {
    await pumpUntilVisible(finder, timeout: timeout);
    final list = widgetList(finder);
    for (final widget in list) {
      await implicitTap(find.byWidget(widget));
    }
  }

  /// Функция чтобы убрать избыточные pump из кода шагов при вводе текста
  Future<void> implicitEnterText(Finder finder, String text, {Duration? timeout}) async {
    await pumpUntilVisible(finder, timeout: timeout);
    try {
      // в обновлении добавили collapsed в TextEditingValue и от этого появились проблемы
      await showKeyboard(finder);
      testTextInput.updateEditingValue(TextEditingValue(text: text));
      await pump();
    }
    // ignore: avoid_catching_errors
    on StateError catch (e) {
      // ignore: only_throw_errors
      throw TestFailure(e.message);
    }
  }

  /// Метод-обертка для customDragUntilVisible чтобы не создавать много ключей для виджетов-скроллов
  Future<void> implicitScrollUntilVisible(
    Finder finder, {
    Offset moveStep = BaseTestGestures.scrollDown,
    Duration? duration,
    int maxIteration = 50,
    Finder? scrollFinder,
    Finder? errorWidget,
  }) async {
    await pumpUntilVisible(finder.changeSkipOffstage(), doThrow: false);
    scrollFinder ??= BaseTestScreen().scroll;
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

  /// Метод который свайпает [view] в направлении [moveStep] пока [finder] не будет обнаружен
  /// [duration] отвечает за задержку между свайпами, [maxIteration] задает максимальное количество свайпов
  /// [errorWidget]
  Future<void> simpleDragUntilVisible(
    Finder finder,
    Finder view,
    Offset moveStep, {
    int maxIteration = 50,
    Duration? duration,
    Finder? errorWidget,
  }) async {
    return TestAsyncUtils.guard<void>(() async {
      await pumpUntilVisible(view);
      bool condition() => finder.evaluate().isEmpty;
      for (var i = 0; i < maxIteration && safeEval<bool>(condition, true); i++) {
        await dragFrom(getCenter(view.first), moveStep);
        await pumpUntilSettled(timeout: duration);
        if (errorWidget != null && errorWidget.evaluate().isNotEmpty) {
          // ignore: only_throw_errors
          throw TestFailure('Error was encountered $errorWidget');
        }
      }
    });
  }
}
