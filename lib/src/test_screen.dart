import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Класс с основными Offset'ами для переиспользования в тестах
/// Направление скролла = направление списка
/// Направление свайпа/флика = направление движения пальца
abstract class TestGestures {
  // скролл вниз
  static const Offset scrollDown = Offset(0, -120);
  static const Offset flickUp = Offset(0, -600);

  // скролл вверх
  static const Offset scrollUp = Offset(0, 120);
  static const Offset flickDown = Offset(0, 600);

  // скролл предметов в стороны, движение пальца инвертировано
  static const Offset carouselRight = Offset(-300, 0);
  static const Offset carouselRightStrong = Offset(-600, 0);
  static const Offset carouselLeft = Offset(300, 0);
  static const Offset carouselLeftStrong = Offset(600, 0);
}

/// Базовый экран с набором основных Finder'ов. На проекте стоит иметь свой базовый экран
/// наследующийся от этого, а экраны фич должны наследоваться от базового экрана.
/// Инстансы экранов должны храниться для удобства в test_screen_library файле
class TestScreen {
  /// любой скролл с типом из списка
  Finder scroll = find.byWidgetPredicate((w) =>
      w is ScrollView ||
      w is SingleChildScrollView ||
      w is NestedScrollView ||
      w is ReorderableListView);

  /// [Text] или [RichText] (если выбран параметр [findRichText]) с полным соответствием
  Finder text(String t, {bool findRichText = false}) => find.text(t, findRichText: findRichText);

  /// [Text] или [RichText] (если выбран параметр [findRichText]) с частичным соответствием
  Finder textPartial(String t, {bool findRichText = false}) =>
      find.textContaining(t, findRichText: findRichText);

  /// крестик
  Finder closeBtn = find
      .byWidgetPredicate((w) => w is Icon && [Icons.close, Icons.cancel_rounded].contains(w.icon));

  /// текстовое поле [TextField] с плейсхолдером/хинтом [text]
  Finder textFieldByLabel(String text) => find.byWidgetPredicate((widget) {
        return widget is TextField &&
            (widget.decoration?.labelText == text || (widget.decoration?.hintText == text));
      });

  /// текстовое поле [TextField] с частичным плейсхолдером/хинтом [text]
  Finder textFieldByLabelPartial(String text) => find.byWidgetPredicate((widget) {
        return widget is TextField &&
            ((widget.decoration?.labelText?.contains(text) ?? false) ||
                (widget.decoration?.hintText?.contains(text) ?? false));
      });
}
