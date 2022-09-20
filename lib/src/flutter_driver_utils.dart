import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart' as integration_test_driver;
import 'package:path/path.dart' as path;

/// Функция для задания времени до выключения экрана у андроид устройств которые подключены к хосту
/// Нужна т.к. при длинных прогонах телефон выключает экран, т.к. автотесты не эмулируют действия юзера.
/// todo https://pub.dev/packages/wakelock - должен позволить не испольовать этот костыль
Future<void> androidScreenDuration({int duration = 2147483647}) async {
  // Выключаем автоматическое выключение экрана на всех адб девайсах раздельно
  final run = await Process.run('adb', ['devices']);
  final dynamic devices = run.stdout;
  if (devices is! String) {
    throw Exception('adb devices returned not String');
  }
  final ids = RegExp(r'\S+(?=\s*device\n+)').allMatches(devices).map((e) => e.group(0));
  for (final id in ids.whereType<String>()) {
    final result = await Process.run(
      'adb',
      ['-s', id, 'shell', 'settings', 'put', 'system', 'screen_off_timeout', '$duration'],
    );
    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
  }
}

/// При падении тестов не создаестся json отчет, поэтому responseDataCallback был вынесен
/// из условия allTestsPassed.
/// На проекте нужно указывать [timeout] т.к. если время прогона будет больше него - отчета не будет
/// По умолчанию передается колбек writeGherkinReports
Future<void> fixedIntegrationDriver({
  Duration timeout = const Duration(minutes: 20),
  integration_test_driver.ResponseDataCallback? responseDataCallback = writeGherkinReports,
}) async {
  final driver = await FlutterDriver.connect();
  final jsonResult = await driver.requestData(null, timeout: timeout);
  final response = Response.fromJson(jsonResult);

  await driver.close();
  // переместил вызов колбека из условия response.allTestsPassed
  if (responseDataCallback != null) {
    await responseDataCallback(response.data);
  }
  if (response.allTestsPassed) {
    //ignore: avoid_print
    print('All tests passed.');
    exit(0);
  } else {
    //ignore: avoid_print
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}

/// Функция для парсинга отчета flutter_gherkin в правильный cucumber.json формат
Future<void> writeGherkinReports(
  Map<String, dynamic>? data, {
  String testOutputFilename = 'integration_response_data',
  String? destinationDirectory,
}) async {
  await integration_test_driver.writeResponseData(
    data,
    testOutputFilename: 'gherkin_reports',
    destinationDirectory: destinationDirectory,
  );

  final dynamic reports = json.decode(data?['gherkin_reports'].toString() ?? '[]');
  if (reports is! List) throw Exception('gherkin report is not a List while it should be');
  for (var i = 0; i < reports.length; i += 1) {
    final Object? reportData = reports.elementAt(i);
    if (reportData is! List) throw TestFailure('For some reason report is not properly working');

    await fs.directory(integration_test_driver.testOutputsDirectory).create(recursive: true);
    final File file = fs.file(path.join(
      integration_test_driver.testOutputsDirectory,
      'report_$i.json',
    ));
    final resultString = const JsonEncoder.withIndent('  ').convert(reportData);
    await file.writeAsString(resultString);
  }
}
