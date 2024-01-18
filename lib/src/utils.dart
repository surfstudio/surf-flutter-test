import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

/// Функция для безопасной обработки условий в implicit действиях
/// В некоторых ситуациях при скроллах или анимациях могут возникать flutter ошибки
/// StateError при взаимодействии "невовремя". Эта функция позволяет их безопасно обрабатывать без падения всего прогона
T safeEval<T>(T Function() func, T errorValue) {
  try {
    return func();
    // ignore: avoid_catching_errors
  } on StateError {
    return errorValue;
  }
}

/// Функция для удобства в pump-методах, которая вычисляет необходимое число повторов проверки условия
/// в зависимости от требуемого времени. Минимальная задержка нужна чтобы не перегружать UI поток
/// проверками условий Finder'ов.
///
/// Почему не использовать Stopwatch или Date? Т.к. время в тестах не всегда реальное (в e2e реальное, в
/// виджет тестах нет), то использовать Stopwatch и подобные техники для timeout нельзя.
int repeatTimes(Duration duration) {
  return (duration.inMicroseconds / TestDelays().minimalInteractionDelay.inMicroseconds).ceil();

}
