import 'package:flutter/material.dart';

import 'screens/player_screen.dart';

void main() {
  runApp(const RadioWahApp());
}

/// Palette ispirata a Radio Wah / Deloitte: nero come base e verde come
/// colore di accento (stesso verde usato per gli elementi attivi sul sito
/// radiowah.deloitte.it).
class RadioWahColors {
  RadioWahColors._();

  static const Color deloitteGreen = Color(0xFF86BC25);
  static const Color accentGreen = Color(0xFF27890D);
  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
}

class RadioWahApp extends StatelessWidget {
  const RadioWahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RadioWahColors.deloitteGreen,
      brightness: Brightness.dark,
      primary: RadioWahColors.deloitteGreen,
      secondary: RadioWahColors.accentGreen,
      surface: RadioWahColors.surface,
    );
    return MaterialApp(
      title: 'Radio Wah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: RadioWahColors.black,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: RadioWahColors.black,
          foregroundColor: RadioWahColors.deloitteGreen,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: RadioWahColors.deloitteGreen,
          foregroundColor: RadioWahColors.black,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: RadioWahColors.deloitteGreen,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: RadioWahColors.deloitteGreen,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: RadioWahColors.deloitteGreen,
        ),
      ),
      home: const PlayerScreen(),
    );
  }
}
