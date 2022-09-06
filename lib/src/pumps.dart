import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

extension PumpedWidgetTester on WidgetTester {
  // TODO(anyone): занялся бы везде рефакторигом документации по методам и не только - выглядит не оч.
  /// Функция для того чтобы пампить определенное время, когда нельзя использовать
  /// pumpAndSettle или обычный pump
  Future<void> pumpForDuration(Duration duration) async {
    final times = repeatTimes(duration);
    for (var i = 0; i < times; i++) {
      await pump(TestDelays().minimalInteractionDelay);
    }
  }

  /// Метод для того, чтобы пампить пока не завершится анимация или до таймаута если анимация долгая
  /// Позволяет пропускать переходы по экранам без использования [pumpForDuration]
  Future<void> pumpUntilSettled({Duration? timeout}) async {
    final times = repeatTimes(timeout ?? TestDelays().defaultPumpTimeout);
    for (var i = 0; i < times && binding.hasScheduledFrame; i++) {
      await pump(TestDelays().minimalInteractionDelay);
    }
  }

  /// Метод для того, чтобы делать pump пока не произойдет условие [condition]
  Future<bool> pumpUntilCondition(
    bool Function() condition, {
    Duration? timeout,
  }) async {
    var instant = true;
    final times = repeatTimes(timeout ?? TestDelays().defaultPumpTimeout);
    for (var i = 0; i < times; i++) {
      // TODO(anyone): можно так писать без явного вызова.
      if (safeEval(condition, false)) {
        // добавляем доп задержку если нашли не сразу - скорее всего идет анимация
        if (!instant) await pumpUntilSettled(timeout: TestDelays().interactionDelay);
        return true;
      }
      await pumpForDuration(TestDelays().minimalInteractionDelay);
      instant = false;
    }
    return false;
  }

  /// Функция для pump пока не будет обнаружен виджет.
  /// [doThrow] нужен в случае если виджет поиска не критичен для сценария
  Future<bool> pumpUntilVisible(
    Finder finder, {
    Duration? timeout,
    bool doThrow = true,
  }) async {
    bool condition() => finder.evaluate().isNotEmpty;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found && doThrow) {
      // TODO(anyone): игнор ж тут не нужен.
      // ignore: only_throw_errors
      throw TestFailure('Target was not found ${finder.description}\n${StackTrace.current}');
    }
    return found;
  }

  // TODO(anyone): стоит описать какое дефолтное время будет выделено на поиск, иначе непонятно.
  // TODO(anyone): аналогично в других местах.
  /// Функция для pump пока не будет обнаружен любой из списка виджетов
  Future<void> pumpUntilVisibleAny(
    List<Finder> finderList, {
    Duration? timeout,
  }) async {
    bool condition() => finderList.any((target) => target.evaluate().isNotEmpty);
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      //ignore: only_throw_errors
      throw TestFailure('None of targets were found ${finderList.map((e) => e.description)}'
          '\n${StackTrace.current}');
    }
  }

  /// Функция для pump пока не пропадет виджет
  /// Может не работать в некоторых ситуациях несмотря на skipOffstage = true
  /// [doThrow] нужен в случае если виджет поиска не критичен для сценария
  Future<bool> pumpUntilNotVisible(
    Finder finder, {
    Duration? timeout,
    bool doThrow = true,
  }) async {
    bool condition() => finder.evaluate().isEmpty;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found && doThrow) {
      // ignore: only_throw_errors
      throw TestFailure('Target did not disappear ${finder.description}\n${StackTrace.current}');
    }
    return found;
  }

  /// Функция для pump пока не пропадет любой из списка виджетов
  Future<void> pumpUntilNotVisibleAny(
    List<Finder> finderList, {
    Duration? timeout,
  }) async {
    bool condition() => finderList.any((target) => target.evaluate().isEmpty);
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      // ignore: only_throw_errors
      throw TestFailure('None of targets did disappear ${finderList.map((e) => e.description)}'
          '\n${StackTrace.current}');
    }
  }

  /// Функция для pump пока на экране не будет [amount] количество [finder]
  Future<void> pumpUntilVisibleAmount(
    Finder finder,
    int amount, {
    Duration? timeout,
  }) async {
    bool condition() => finder.evaluate().length == amount;
    final found = await pumpUntilCondition(condition, timeout: timeout);
    if (!found) {
      // ignore: only_throw_errors
      throw TestFailure(
        'There were not $amount targets ${finder.description}\n${StackTrace.current}',
      );
    }
  }
}
