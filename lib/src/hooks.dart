import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

/// Хук который добавляет стабильности скриншотам при падении за счет pumpUntilSettled
/// Так же использует RenderElement способ взятия скриншотов, т.к. на ios не работает нативный способ
/// После сценария сбрасывает debugDefaultTargetPlatformOverride т.к. flutter_test проверяет это
class ConvenienceHook extends Hook {
  @override
  Future<void> onAfterStep(
    World world,
    String step,
    StepResult stepResult,
  ) async {
    if (stepResult.result == StepExecutionResult.fail ||
        stepResult.result == StepExecutionResult.error ||
        stepResult.result == StepExecutionResult.timeout) {
      try {
        final screenshotData = await takeScreenshot(world);
        world.attach(screenshotData, 'image/png', step);
        //ignore:avoid_catches_without_on_clauses
      } catch (e, st) {
        world.attach('Failed to take screenshot\n$e\n$st', 'text/plain', step);
      }
    }
  }

  Future<String> takeScreenshot(World world) async {
    if (world is! FlutterWidgetTesterWorld) {
      throw TestFailure('E2E hook works only with FlutterWidgetTesterWorld objects');
    }
    final appDriver = world.appDriver;
    if (appDriver is! WidgetTesterAppDriverAdapter) {
      throw TestFailure('E2E hook works only with WidgetTesterAppDriverAdapter objects');
    }
    // Если тест падает во время анимации, может быть ошибка создания скриншота
    final tester = world.appDriver.nativeDriver;
    await tester.pumpUntilSettled(timeout: TestDelays().longInteractionDelay);
    // ошибка MissingPluginException на айос, поэтому делаем скриншот по верстке
    final bytes = await appDriver.takeScreenshotUsingRenderElement();

    return base64Encode(bytes);
  }

  @override
  Future<void> onAfterScenario(
    TestConfiguration config,
    String scenario,
    Iterable<Tag> tags, {
    bool passed = true,
  }) async {
    debugDefaultTargetPlatformOverride = null;
  }
}
