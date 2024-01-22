import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

extension PumpedWidgetTester on WidgetTester {
  /// Метод для ожидания времени [duration] между действиями
  /// Непосредственно в шагах тестов лучше использовать другие, более неявные, ожидания или же
  /// использовать implicit действия.
  ///
  /// По результату отличается от pump(duration) более плавным обновлением UI и более стабильной работой
  /// в условиях integration_test
  Future<void> pumpForDuration(Duration duration) async {
    final times = repeatTimes(duration);
    for (var i = 0; i < times; i++) {
      await pump(TestDelays().minimalInteractionDelay);
    }
  }

  /// Метод для ожидания завершения всех анимаций в течении [timeout]
  /// Является более безопасной альтернативой pumpAndSettle, т.к. у него большой [timeout] по умолчанию
  /// и выброс ошибки в случае таймаута.
  ///
  /// Полезен в ситуациях когда нужно кроме ожидания появления виджета убедиться что можно взаимодействовать,
  /// не полагаясь при этом на жесткие ожидания через [pumpForDuration]
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> pumpUntilSettled({Duration? timeout}) async {
    final times = repeatTimes(timeout ?? TestDelays().defaultPumpTimeout);
    for (var i = 0; i < times && binding.hasScheduledFrame; i++) {
      await pump(TestDelays().minimalInteractionDelay);
    }
  }

  /// Метод для ожидания какого-то события [condition]
  /// Является базовым методом для многих implicit действий, в явном виде может использоваться
  /// для единоразовых кастомных ожиданий, например ожидания пока виджет сменит состояние итд
  ///
  /// В большинстве случаев обеспечивает flake-safety самостоятельно и не требует дополнительных
  /// pumpUntil методов. Это значит что в большинстве случаев безопасно использовать implicit действие
  /// и проблем с анимациями быть не должно
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<bool> pumpUntilCondition(
    bool Function() condition, {
    Duration? timeout,
  }) async {
    var instant = true;
    final times = repeatTimes(timeout ?? TestDelays().defaultPumpTimeout);
    for (var i = 0; i < times; i++) {
      if (safeEval(condition, false)) {
        // добавляем доп задержку если нашли не сразу - скорее всего идет анимация
        if (!instant) {
          await pumpUntilSettled(timeout: TestDelays().interactionDelay);
        }
        return true;
      }
      await pumpForDuration(TestDelays().minimalInteractionDelay);
      instant = false;
    }
    return false;
  }

  /// Метод для ожидания пока не будет виден виджет [finder].
  /// Является основным implicit действием в тестировании т.к. позволяет избежать boilerplate на
  /// почти любом действии.
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  /// [doThrow] отвечает за факт возвращения ошибки если виджет не был найден.
  /// Если после загрузки виджета нужно проверить его наличие через expect, то можно передать false.
  /// Если после вызова метода будет проверка expect стоит передать false т.к. тогда ошибка будет более подробной
  /// Пример:
  /// ```dart
  ///   await pumpUntilVisible(finder, timeout: timeout, doThrow: false);
  ///   expect(finder, findsOneWidget);
  /// ```
  Future<bool> pumpUntilVisible(
    Finder finder, {
    Duration? timeout,
    bool doThrow = true,
  }) async {
    bool condition() => finder.evaluate().isNotEmpty;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found && doThrow) {
      throw TestFailure(
          'Target was not found ${finder.description}\n${StackTrace.current}');
    }
    return found;
  }

  /// Метод для ожидания пока не будет виден любой виджет из списка [finderList].
  /// Полезен для ожидания одного из событий, например мы ждем появления чекбокса с вкл или выкл состоянием
  /// и если он выкл то включаем его.
  /// Пример:
  /// ```dart
  /// // оба Finder'а имеют флаг skipOffstage = false
  /// await tester.pumpUntilVisibleAny([openedFinder, closedFinder]);
  /// if (openedFinder.evaluate().isEmpty) {
  ///   await tester.simpleScrollUntilVisible(closedFinder);
  ///   await tester.implicitTap(closedFinder.hitTestable());
  /// }
  /// ```
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> pumpUntilVisibleAny(
    List<Finder> finderList, {
    Duration? timeout,
  }) async {
    bool condition() =>
        finderList.any((target) => target.evaluate().isNotEmpty);
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      //ignore: only_throw_errors
      throw TestFailure(
          'None of targets were found ${finderList.map((e) => e.description)}'
          '\n${StackTrace.current}');
    }
  }

  /// Метод для ожидания пока виджет не пропадет виджет [finder].
  /// Полезен в проверках на пропадание элемента или если какой то объект перегораживает взаимодействие,
  /// например снек мешает тапнуть на кнопку.
  /// Может не работать в некоторых ситуациях несмотря на skipOffstage = true, в таком случае стоит
  /// использовать hitTestable
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  /// [doThrow] отвечает за факт возвращения ошибки если виджет не был найден.
  /// Если после загрузки виджета нужно проверить его наличие через expect, то можно передать false.
  /// Если после вызова метода будет проверка expect стоит передать false т.к. тогда ошибка будет более подробной
  Future<bool> pumpUntilNotVisible(
    Finder finder, {
    Duration? timeout,
    bool doThrow = true,
  }) async {
    bool condition() => finder.evaluate().isEmpty;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found && doThrow) {
      throw TestFailure(
          'Target did not disappear ${finder.description}\n${StackTrace.current}');
    }
    return found;
  }

  /// Метод для ожидания пока не пропадет любой виджет из списка [finderList].
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> pumpUntilNotVisibleAny(
    List<Finder> finderList, {
    Duration? timeout,
  }) async {
    bool condition() => finderList.any((target) => target.evaluate().isEmpty);
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      throw TestFailure(
          'None of targets did disappear ${finderList.map((e) => e.description)}'
          '\n${StackTrace.current}');
    }
  }

  /// Метод для ожидания пока на экране не будет [amount] виджетов [finder].
  /// Важен для неявных действий т.к. большинство их них подразумевают что виджет будет один,
  /// а по умолчанию выбирать first виджет из списка не безопасно.
  ///
  /// [timeout] по умолчанию - defaultPumpTimeout
  Future<void> pumpUntilVisibleAmount(
    Finder finder,
    int amount, {
    Duration? timeout,
  }) async {
    bool condition() => finder.evaluate().length == amount;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      throw TestFailure(
        'There were not $amount targets ${finder.description}\n${StackTrace.current}',
      );
    }
  }

  /// Метод для ожидания пока на экране будет не менее [amount] виджетов [finder].
  Future<void> pumpUntilVisibleAtLeastNWidgets(
    Finder finder,
    int amount, {
    Duration? timeout,
  }) async {
    bool condition() => finder.evaluate().length >= amount;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      throw TestFailure(
        'There were less than $amount targets ${finder.description}\n${StackTrace.current}',
      );
    }
  }
}
