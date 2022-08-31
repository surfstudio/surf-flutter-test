import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension BasicExtendedFinders on Finder {
  /// позволяет создать копию Finder'а с измененным skipOffstage параметром
  Finder changeSkipOffstage({bool skipOffstage = false}) =>
      _WidgetChangeOffstageFinder(this, skipOffstage: skipOffstage);
}

/// Finder чтобы можно было на лету поменять свойство skipOffstage.
/// Нужно т.к. поле skipOffstage является финальным и нужно делать еще один Finder, что неудобно.
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
