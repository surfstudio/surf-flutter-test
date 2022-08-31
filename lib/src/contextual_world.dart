import 'dart:convert';

import 'package:flutter_gherkin/flutter_gherkin.dart';

/// World который позволяет передавать данные внутри сценария и работать с учетными данными
class ContextualWorld extends FlutterWidgetTesterWorld {
  final Map<String, String> profile;
  final Map<String, Map<String, String>> credentials;
  final Map<String, dynamic> _scenarioContext = <String, dynamic>{};

  ContextualWorld({required this.credentials, required this.profile});

  @override
  void dispose() {
    super.dispose();
    _scenarioContext.clear();
  }

  /// получить данные из контекста
  T getContext<T>(String key) {
    return _scenarioContext[key] as T;
  }

  /// сохранить данные в контексте сценария
  //ignore: avoid_annotating_with_dynamic
  void setContext(String key, dynamic value) {
    _scenarioContext[key] = value;
  }

  /// прикрепить скриншот к отчету
  Future<void> attachScreenshot() async {
    final bytes = await appDriver.screenshot();
    attach(base64Encode(bytes), 'image/png');
  }

  /// прикрепить текстовые данные к отчету
  void attachText(String data) {
    attach(data, 'text/plain');
  }
}
