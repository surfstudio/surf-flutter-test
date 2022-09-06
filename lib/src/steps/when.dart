import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

// TODO(anyone): стоит на всё это написать хотя бы верхнеуровневую доку с примером что и как использовать
// TODO(anyone): что в колбэке появился тестер для дальнейшего использования
GenericFunctionStepDefinition<TWorld> testerWhen<TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (StepContext<TWorld> context) => onInvoke(
      context,
      context.world.rawAppDriver,
    ),
    0,
    configuration: configuration,
  );
}

GenericFunctionStepDefinition<TWorld> testerWhen1<TInput1, TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    TInput1 input1,
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (TInput1 input1, StepContext<TWorld> context) => onInvoke(
      input1,
      context,
      context.world.rawAppDriver,
    ),
    1,
    configuration: configuration,
  );
}

GenericFunctionStepDefinition<TWorld>
    testerWhen2<TInput1, TInput2, TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    TInput1 input1,
    TInput2 input2,
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (TInput1 input1, TInput2 input2, StepContext<TWorld> context) => onInvoke(
      input1,
      input2,
      context,
      context.world.rawAppDriver,
    ),
    2,
    configuration: configuration,
  );
}

GenericFunctionStepDefinition<TWorld>
    testerWhen3<TInput1, TInput2, TInput3, TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    TInput1 input1,
    TInput2 input2,
    TInput3 input3,
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (TInput1 input1, TInput2 input2, TInput3 input3, StepContext<TWorld> context) => onInvoke(
      input1,
      input2,
      input3,
      context,
      context.world.rawAppDriver,
    ),
    3,
    configuration: configuration,
  );
}

GenericFunctionStepDefinition<TWorld>
    testerWhen4<TInput1, TInput2, TInput3, TInput4, TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    TInput1 input1,
    TInput2 input2,
    TInput3 input3,
    TInput4 input4,
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (TInput1 input1, TInput2 input2, TInput3 input3, TInput4 input4, StepContext<TWorld> context) {
      return onInvoke(
        input1,
        input2,
        input3,
        input4,
        context,
        context.world.rawAppDriver,
      );
    },
    4,
    configuration: configuration,
  );
}

GenericFunctionStepDefinition<TWorld> testerWhen5<TInput1, TInput2, TInput3, TInput4, TInput5,
    TWorld extends FlutterWidgetTesterWorld>(
  Pattern pattern,
  Future<void> Function(
    TInput1 input1,
    TInput2 input2,
    TInput3 input3,
    TInput4 input4,
    TInput5 input5,
    StepContext<TWorld> context,
    WidgetTester tester,
  )
      onInvoke, {
  StepDefinitionConfiguration? configuration,
}) {
  return GenericFunctionStepDefinition<TWorld>(
    pattern,
    (
      TInput1 input1,
      TInput2 input2,
      TInput3 input3,
      TInput4 input4,
      TInput5 input5,
      StepContext<TWorld> context,
    ) {
      return onInvoke(
        input1,
        input2,
        input3,
        input4,
        input5,
        context,
        context.world.rawAppDriver,
      );
    },
    4,
    configuration: configuration,
  );
}
