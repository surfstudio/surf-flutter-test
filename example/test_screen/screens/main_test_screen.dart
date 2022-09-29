import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

class MainTestScreen extends TestScreen {
  /// кнопка редактирования профиля на главном экране
  final Finder editProfileBtn = find.widgetWithText(ElevatedButton, 'Edit profile');
}
