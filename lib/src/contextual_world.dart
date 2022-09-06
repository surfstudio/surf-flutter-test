import 'dart:convert';

import 'package:flutter_gherkin/flutter_gherkin.dart';

/// World который позволяет передавать данные внутри сценария и работать с учетными данными
class ContextualWorld extends FlutterWidgetTesterWorld {
  // TODO(anyone): не думали ли над более удобным форматом взаимодействия? вместо хэш таблицы
  // TODO(anyone): воткнуть сюда абстрактный класс по профилю, от которого можно будет наследоваться
  // TODO(anyone): и использовать удобную типизацию тут, + при получении значения оно не будет nullable
  // TODO(anyone): как в случае с хэш таблицей
  final Map<String, String> profile;
  // TODO(anyone): аналогично комменту выше
  final Map<String, Map<String, String>> credentials;
  // TODO(anyone): аналогично комменту выше
  final Map<String, dynamic> _scenarioContext = <String, dynamic>{};

  ContextualWorld({required this.credentials, required this.profile});

  @override
  void dispose() {
    super.dispose();
    _scenarioContext.clear();
  }

  /// получить данные из контекста
  T getContext<T>(String key) {
    // TODO(anyone): если всё таки хочется так делать, стоит сделать это безопасно через type check
    return _scenarioContext[key] as T;
  }

  /// сохранить данные в контексте сценария
  // TODO(anyone): Object? лучше чем dynamic
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
