import 'dart:convert';

import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';

/// World который позволяет передавать данные внутри сценария и работать с учетными данными
/// В шагах нужно указывать тип пользователя через дженерик
/// Для задания пользователя в шаге "использую аккаунт" нужно использовать [setUser] с типом аккаунта из шага
/// Для получения объекта User в шаге нужно использовать get user
class ContextualWorld<U> extends FlutterWidgetTesterWorld {
  final Map<String, U> _credentialProfile;
  final Map<String, Object?> _scenarioContext = <String, Object?>{};
  final String _userKey = 'current_user_key';

  U get user => getContext<U>(_userKey);

  ContextualWorld(this._credentialProfile);

  void setUser(String userType) {
    final result = _credentialProfile[userType];
    if (result is! U) {
      throw TestFailure(
        'There is no user $userType in credentials of this context. Credentials are: $_credentialProfile}',
      );
    }
    setContext(_userKey, result);
  }

  @override
  void dispose() {
    super.dispose();
    _scenarioContext.clear();
  }

  /// получить данные из контекста
  C getContext<C>(String key) {
    final result = _scenarioContext[key];
    if (result is! C) {
      throw TestFailure("Context doesn't contain value with key $key and value type $C");
    }
    return result;
  }

  /// сохранить данные в контексте сценария
  void setContext(String key, Object? value) {
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
