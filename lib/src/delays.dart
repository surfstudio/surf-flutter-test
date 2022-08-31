class TestDelays {
  /// задержки для запроса
  final Duration shortRequestDelay = const Duration(seconds: 5);
  final Duration requestDelay = const Duration(seconds: 60);
  final Duration longRequestDelay = const Duration(seconds: 150);

  /// задержки для взаимодействия
  final Duration minimalInteractionDelay = const Duration(milliseconds: 150);
  final Duration shortInteractionDelay = const Duration(milliseconds: 300);
  final Duration interactionDelay = const Duration(milliseconds: 500);
  final Duration longInteractionDelay = const Duration(seconds: 1);
  final Duration defaultPumpTimeout = const Duration(seconds: 10);
}
