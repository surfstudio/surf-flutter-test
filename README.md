Пакет в котором содержатся последние наработки Surf по Е2Е и Widget автотестам с использованием
integration_test, flutter_test и flutter_gherkin

## Features

- integration_test + flutter_test:
  - Базовые локаторы которые будут полезны всегда в TestScreen
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
    url: https://github.com/surfstudio/surf-flutter-test
    ref: main
```

## Usage

Пакет можно использовать по разному, но основные варианты такие:

### testerGiven/testerWhen/testerThen

В flutter_gherkin для написания тестов используются шаги, которые реализуются через given/when/then функции с колбеками
в которых мы выполняем свой код. Для удобства в этой библиотеке были созданы кастомные варианты таких функций которые
меняют сигнатуру колбека.
В них теперь кроме параметров шага и context передается tester параметр - объект класса WidgetTester через который и
происходит все тестирование.
Сравнение использования (больше примеров можно увидеть в example):

```dart
// стандартная реализация
when<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context) async {
    final tester = context.world.rawAppDriver;
    await tester.implicitTap(mainTestScreen.editProfileBtn);
  },
),
```

```dart
// улучшенный вариант
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.implicitTap(mainTestScreen.editProfileBtn);
  },
),
```

Такое изменение позволяет убрать boilerplate код из почти-что каждого шага
Аналогичное поведение и для given/then шагов.

### pumps

В integration и widget тестах между действиями нужно делать pump. Нужно это для того чтобы приложение работало из-за
FakeAsync, так и для того чтобы ждать пока не случится какое то событие. Эдакий аналог sleep(duration).
В шагах тестов нужно регулярно чего-то ждать, что не очень удобно. Много в каких фреймворках вводится понятие
"неявное ожидание", подразумевающее что мы просто описываем действия, а фреймворк сам ждет пока сможет его выполнить.
Эту цель и пытаются выполнить pump методы.

Пример:

```dart
// стандартная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.pump(); // если запрос и ожидания результата, то этого мало
    await tester.pumpAndSettle(); // если бесконечная анимация, то тест упадет
    await tester.tap(mainTestScreen.editProfileBtn);
  },
),
```

```dart
// улучшенный вариант с pump
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.pumpUntilVisibleAmount(mainTestScreen.editProfileBtn, 1);
    await tester.tap(mainTestScreen.editProfileBtn);
  },
),
```

### implicitActions

Кроме ожиданий с виджетами еще нужно взаимодействовать. Причем зачастую после этих самых ожиданий. Поэтому, их можно
объединить чтобы не писать лишний код. Кроме ожиданий эти действия могут иметь новую логику для удобства.

```dart
// стандартная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.pumpUntilVisibleAmount(mainTestScreen.editProfileBtn, 1);
    await tester.tap(mainTestScreen.editProfileBtn);
    // пример с скроллом
    await tester.pumpUntilVisible(mainTestScreen.scroll);
    await tester.dragUntilVisible(mainTestScreen.listItem, mainTestScreen.scroll);
  },
),
```

```dart
// улучшенный вариант
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.implicitTap(mainTestScreen.editProfileBtn);
    // пример с скроллом
    await tester.implicitScrollUntilVisible(mainTestScreen.listItem);
  },
),
```

Как видим нам нужно просто тапнуть и пролистать до виджета, и не нужно писать ожидания или задавать finder для
scrollView (хотя в некоторых случаях стоит использовать simpleDragUntilVisible т.к. поиск scrollView может занимать
много времени).

### Finders

#### changeSkipOffstage

В тестах часто нужен Finder с возможностью посмотреть "за экран" с помощью skipOffstage: true параметра. Однако это поле
у класса Finder финальное, а делать два Finder'а каждый раз когда хочется такого это избыточно. Поэтому был создан
Finder-обертка, который позволяет поменять любому Finder'у этот параметр на лету.

Наглядный пример из метода implicitScrollUntilVisible:

```dart
Future<void> implicitScrollUntilVisible(
  Finder finder, {
  Offset moveStep = TestGestures.scrollDown,
  Duration? duration,
  int maxIteration = 50,
  Finder? scrollFinder,
  Finder? errorWidget,
}) async {
  // т.к. мы скроллим, Finder вполне себе может быть не виден на экране
  await pumpUntilVisible(finder.changeSkipOffstage(), doThrow: false);
  scrollFinder ??= TestScreen().scroll;
  // для поиска скролла нам тоже нужен виджет которого скорее всего не видим
  final scrollView = find.ancestor(of: finder.changeSkipOffstage(), matching: scrollFinder);
  await simpleDragUntilVisible(
    finder.hitTestable(), // а тут уже проверяем hitTestable т.к. иногда виджет видно до того как на него можно нажать
    scrollView,
    moveStep,
    duration: duration,
    maxIteration: maxIteration,
    errorWidget: errorWidget,
  );
}
```

### Screens

Хорошим паттерном автотестов является вынос Finder'ов в отдельные классы для удобства и читаемости. Так называемый
Page Object. Часто используемые Finder'ы были собраны в TestScreen. Кроме того, экраны фич нужно наследовать от
этого класса (или его потомка если нужно что-то изменить на глобальном уровне) чтобы можно было переопределять общие
элементы на экранах и не было нужды использовать такие общие элементы через отдельную "базовую" страницу.
Изначально экраны были статическими т.к. по сути объект не несет в себе никакой ценности для тестов, но у статических
полей нет наследования поэтому пришли к варианту с хранением в общем файле.

```dart
// реализация без экранов
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    // плохо т.к. нельзя переиспользовать одинаковый виджет в разных тестах
    await tester.implicitTap(find.widgetWithText(ElevatedButton, 'Edit profile'));
  },
),
```

```dart
// улучшенный вариант
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    // mainTestScreen хранится в библиотеке скринов, а класс содержит поле editProfileBtn = finder из прошлого примера
    await tester.implicitTap(mainTestScreen.editProfileBtn);
  },
),
```

### TestDelays

Во время тестирования часто нужно полагаться на объекты Duration типа. В тех же ожиданиях нужно регулировать таймауты
итд. Для этого есть класс TestDelays, в котором содержатся базовые виды задержек. Этот класс можно переопределить на
своем проекте для изменения дефолтных значений. Инстансы таких классов стоит хранить там же где и инстансы страниц.

```dart
// стандартная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    await tester.pumpUntilSettled(timeout: const Duration(seconds:2)); // не получается переиспользовать
    await tester.tap(mainTestScreen.editProfileBtn);
  },
),
```

```dart
// улучшенная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    // testDelays = TestDelays(); в библиотеке экранов
    await tester.pumpUntilSettled(timeout: testDelays.interactionDelay);
    await tester.tap(mainTestScreen.editProfileBtn);
  },
),
```

### TestGestures

По аналогии с Duration, в тестах нужно использоваться объекты Offset, для различных свайпов итд. Хранить их стоит в
файлах страниц, т.к. они абстрактные классы с статичными полями

```dart
// стандартная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    // нельзя переиспользовать + не особо интуитивно что происходит
    await tester.impicitScrollUntilVisible(finder, moveStep: const Offset(0, -120));
  },
),
```

```dart
// улучшенная реализация
testerWhen<ContextualWorld>(
  RegExp(r'Я перехожу к редактированию профиля$'),
  (context, tester) async {
    // переиспользуемый Offset + понятно в какую сторону будет скролл
    await tester.impicitScrollUntilVisible(finder, moveStep: TestGestures.scrollDown);
  },
),
```

### ContextualWorld

Иногда в сценариях бывает необходимость передать данные, например для проверок вроде "проверить что значение на
следующем экране такое же как и на прошлом". Кроме того часто в приложениях встречается авторизация. Чтобы не указывать
в сценариях учетные данные каждый раз, в ContextualWorld можно передать *профиль* - объект Map который соотносит
*смысловое название* учетки с конкретными данными для авторизации. Это нужно для того, чтобы можно было простым конфигом
поменять сервер и не трогать gherkin сценарии.

Пример:

```dart
// создаем вариант юзера под нужды проекта
class UserImpl extends User {
  final String login;
  final String password;
  final String pin;
  final String otp;

  UserImpl(this.login, this.password, this.pin, this.otp);
}

// создаем класс учеток для переиспользования
abstract class DevUsers {
  static UserImpl test = UserImpl('test', '1234', '1111', '1111');
}

// создаем профиль
final devCredentials = <String, UserImpl>{
  'test_acc': DevUsers.test,
};

// в gherkin_suite_test создаем World и передаем в него профиль
createWorld: (config) => Future.value(ContextualWorld(devCredentials))

testerGiven1<String, ContextualWorld>(
  RegExp(r'Я использую аккаунт {string}$'),
  (userType, context, tester) async {
    context.world.setUser(userType); // сохраняем юзера в given шаге чтобы использовать в других шагах
  },
),
testerWhen<ContextualWorld<UserImpl>>( // указываем тип юзера чтобы получить доступ к полям
  RegExp(r'Я авторизуюсь по логину$'),
  (context, tester) async {
    final user = context.world.user; // юзер уже сохранен
    await tester.implicitEnterText(authTestScreen.loginField, user.login); // вводим логин
    await tester.implicitTap(authTestScreen.loginBtn);
  },
),
testerWhen1<String, ContextualWorld>(
  RegExp(r'Я указываю дату рождения {string}$'),
  (birthdate, context, tester) async {
    final finder = profileTestScreen.birthdayField;
    await tester.pumpUntilVisible(finder);
    tester.widget<TextField>(finder).controller?.text = birthdate;
    await tester.pump();
    // параметры хранятся в файлах с страницей фичи в виде абстрактного класса с статическими полями
    context.world.setContext(ProfileTestParams.birthdate, birthdate); // запоминаем ДР
  },
),
testerThen<ContextualWorld>(
  RegExp(r'Я вижу заполненное поле даты рождения$'),
  (context, tester) async {
    await tester.pumpUntilVisible(profileTestScreen.birthdayField);
    final birthdate = tester.widget<TextField>(profileTestScreen.birthdayField).controller?.text;
    expect(birthdate, context.world.getContext<String>(ProfileTestParams.birthdate)); // достаем данные из контекста
  },
),
```

Как видим, для авторизации нам достаточно в сценарии один раз указать тип аккаунта, вроде 'test_acc', и в точке входа
указать профиль в конфиге. Дальше можно в шагах получать сущность пользователя и использовать данные по своему
усмотрению. С передачей данных вроде тоже все понятно.

### Hooks

В flutter_gherkin возможно использование хуков - блоков кода которые выполняются после (или перед) определенными
событиями, например после завершения теста. В этой библиотеке есть полезный хук - ConvenienceHook. Его функции такие:

1. При ошибке шага, делать дополнительный pumpUntilSettled и делать скриншот с помощью рендера. Так скриншоты становятся
   стабильными на всех платформах и нет проблем во время попытки сделать скриншот.
2. После завершения сценария сбрасывается debugDefaultTargetPlatformOverride т.к. на нее часто жалуются assert'ы в
   flutter_test библиотеке

Добавляется этот хук также как и другие:

```dart
// gherkin_suite_test.dart конфиг
hooks: [
  ConvenienceHook(),
],
```

### flutter_driver utils

Кроме фич которые помогают непосредственно с integration_test + flutter_gherkin, есть еще полезные вещи при работе с
частью flutter_driver.

#### Increase Android device wake time above limit

После определенного количества тестов оин начинают длиться дольше 30 минут которые можно выставить в настройках андроида
для засыпания. Плюс для автоматизации увеличения этого времени есть функция androidScreenDuration, которую нужно
вызывать в flutter_driver сегменте тестов, т.к. только этот код выполняется на хосте. Функция сама по себе ищет
подключенные устройства и всем им выставляет настройку.

#### fixedIntegrationDriver

Основная цель использования flutter_driver в е2е тестах - получение отчета, т.к. тесты выполняются на устройстве.
Flutter driver тут выступает в роли "получить ответ от integration_test".
В инициализации integrationDriver есть проблема - если тесты падают с ошибками, то колбек с обработкой отчета не
вызывается, т.е. отчет мы получим только если все тесты пройдут успешно, что не очень удобно.
Поэтому в данном пакете добавлен fixedIntegrationDriver, который исправляет эту ошибку, а так же использует
writeGherkinReports колбек по умолчанию который парсит отчет в cucumber.json формат.

Пример main функции flutter_driver с доработками

```dart
Future<void> main() async {
  integration_test_driver.testOutputsDirectory = 'integration_test/gherkin/reports';

  await androidScreenDuration();

  return fixedIntegrationDriver(
    timeout: const Duration(minutes: 120), // таймаут на все тесты, должен быть больше чем общее время прогона
  );
}


```

### Extensions

Кроме всего прочего, в проекте есть StringExtension который содержит метод cleanEllipsisOverflow.

Пример:
```dart
Flexible(
  child: Text(
    title.overflow, // добавляются символы
    key: ProductTestKeys.productId(product.accountId ?? 0),
    style: (product is Card ? StyleRes.regular14White : StyleRes.regular14)
        .copyWith(height: cardTextHeight),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
),

testerThen<ContextualWorld>(
  RegExp(r'Я вижу новое имя продукта в деталке$'),
  (context, tester) async {
    final id = context.world.getContext<int>(ProductTestParams.renamedProduct);
    final newName = context.world.getContext<String>(ProductTestParams.newName);
    await tester.pumpUntilVisible(ProductTestScreen.productNameId(id));
    final actualNameWidget = tester.firstWidget<Text>(ProductTestScreen.productNameId(id));
    final actualName = actualNameWidget.data?.cleanOverflow; // очищаем символы
    expect(actualName, newName); // сравнение работает
  },
),
```
