import 'package:flutter/material.dart';

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  static ThemeData get dark => ThemeData(
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121318),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFAF6EE),
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFAF6EE)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF232530),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFAF6EE)),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFAF6EE)),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFAF6EE)),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFFAF6EE)),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFAF6EE)),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFFAF6EE)),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFAF6EE)),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFAF6EE)),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFAF6EE)),
      bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xFF8E92A6)),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFAF6EE)),
    ),
  );
}
