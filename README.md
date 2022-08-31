Пакет в котором содержатся последние наработки Surf по Е2Е и Widget автотестам с использованием
integration_test, flutter_test и flutter_gherkin

## Features

- integration_test + flutter_test:
    - Базовые локаторы которые будут полезны всегда в BaseTestScreen
    - Дополнительный Finder который позволяет менять skipOffstage свойство у существующих Finder'ов
    - Задержки Duration которые часто используются
    - Неявные ожидания разных видов
    - Неявные действия использующие ожидания (тапы, свайпы, ввод текстов итд)
    - Фикс создания отчета json при падении тестов в flutter_driver
- flutter_gherkin:
    - given/when/then с передачей WidgetTester в колбеке для удобства
    - ContextualWorld который позволяет передавать данные внутри сценария
    - Хук для создания скриншота при падении и фикса ошибки с debugDefaultTargetPlatformOverride
    - Обработка json отчета в формат пригодный для cucumber-html-reporter

## Getting started

Для использования достаточно добавить пакет в dev-зависимости в pubspec.yaml таким образом:

```yaml
surf_flutter_test:
  git:
    url: https://github.com/surfstudio/surf_flutter_test
    ref: main
```

## Usage

Пакет можно использовать по разному, но основные варианты такие:

1. В шагах используйте implicit действия, а так же pump из `implicit_actions.dart`и `pumps.dart`
   При проверке условий используется функция `safeEval`, возможно она будет полезна в других местах.
2. При написании шагов используйте testerWhen/Then/Given чтобы не писать в каждом
   шаге `tester = context.world.rawAppDriver`.
3. При описании страниц в `test_screen/screens` наследуйтесь от `BaseTestScreen`, инстансы страниц собирайте
   в `test_screen_library.dart`.
4. Чтобы была возможность передавать контекст внутри сценария используйте ContextWorld в `gherkin_suite_test.dart`.
5. Для фикса ошибки из-за платформы и чтобы скриншоты создавались безопасно используйте ConvenienceHook.
6. В местах где нужны `Duration`, используйте `TestDelays`. Инстансы задержек можно хранить в библиотеке страниц.
7. В местах где нужны `Offset` используйте `BaseTestGestures`. Для фич создавайте свои классы и храните в том же файле что и страница.
8. Для изменения видимости Finder'а используйте `Finder.changeSkipOffstage`.
9. Для задания времени до выключения экрана на Android устройствах используйте `androidScreenDuration` в main блоке
   вызова flutter_driver.
10. Для фикса создания отчета при падении тестов, во время инициализации flutter_driver используйте
    функцию `fixedIntegrationDriver`.
    В качестве колбека для драйвера используется `writeGherkinReports` по умолчанию.
11. Так же есть небольшая функция помогающая очистить строки от неразрывных пробелов `cleanOverflow`.
