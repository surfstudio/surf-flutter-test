import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Направление скролла = направление списка
/// Направление свайпа/флика = направление движения пальца
abstract class BaseTestGestures {
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
class BaseTestScreen {
  /// любой скролл с типом из списка
  Finder scroll = find.byWidgetPredicate((w) =>
      w is ScrollView ||
      w is SingleChildScrollView ||
      w is NestedScrollView ||
      w is ReorderableListView);

  // (w) => [CustomScrollView, SingleChildScrollView, ListView].contains(w.runtimeType));

  /// [Text] с частичным совпадением
  Finder textPartial(String text) =>
      find.byWidgetPredicate((w) => w is Text && (w.data?.contains(text) ?? false));

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
