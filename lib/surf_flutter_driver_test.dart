library surf_flutter_test;

/// ***************************************
/// Для flutter_driver недопустим импорт dart:ui который используется в integration_test, поэтому
/// отдельный файл-библиотека для вещей полезных для flutter_driver
/// ***************************************

export 'src/flutter_driver_utils.dart';
