import 'package:surf_flutter_test/surf_flutter_test.dart';

/// Функция для удобной обработки условий в действиях
T safeEval<T>(T Function() func, T errorValue) {
  try {
    return func();
    // ignore: avoid_catching_errors
  } on StateError {
    return errorValue;
  }
}

/// Функция для удобства в функциях pump
int repeatTimes(Duration duration) {
  return (duration.inMicroseconds / TestDelays().minimalInteractionDelay.inMicroseconds).ceil();
}

/// Расширения для работы со строками в тестах
extension StringExtension on String {
  /// при использовании ellipsis использует пробелы 200B и поэтому текст не совпадает
  /// https://github.com/flutter/flutter/issues/18761
  String get cleanOverflow => replaceAll('\u{200B}', '');
}
