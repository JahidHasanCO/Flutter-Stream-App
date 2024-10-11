import 'package:flutter/material.dart';

extension ThemeExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
}


extension ThemeDataExt on ThemeData {
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}
