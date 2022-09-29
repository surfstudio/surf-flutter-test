import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension BasicExtendedFinders on Finder {
  /// позволяет создать копию Finder'а с измененным skipOffstage параметром
  Finder changeSkipOffstage({bool skipOffstage = false}) =>
      _WidgetChangeOffstageFinder(this, skipOffstage: skipOffstage);
}

/// Finder-обертка, позволяющий менять skipOffstage свойство у передаваемого finder'а.
/// Свойство final, поэтому этот Finder хранит в себе оригинальный Finder и применяет его в apply.
class _WidgetChangeOffstageFinder extends Finder {
  /// Finder который обертываем
  final Finder finder;

  @override
  String get description => finder.description;

  _WidgetChangeOffstageFinder(this.finder, {bool skipOffstage = false})
      : super(skipOffstage: skipOffstage);

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }
}
