import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Edge-to-edge system bars; call when theme brightness changes.
abstract final class AppSystemUi {
  static void applyForBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  static void applyFromContext(BuildContext context) {
    applyForBrightness(Theme.of(context).brightness);
  }
}
