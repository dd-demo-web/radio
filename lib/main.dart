import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/player_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'services/radio_player_controller.dart';

void main() {
  runApp(const RadioWahApp());
}

class RadioWahColors {
  RadioWahColors._();

  static const Color deloitteGreen = Color(0xFFC4D600); // Matches prototype #C4D600
  static const Color accentGreen = Color(0xFF27890D);
  static const Color black = Color(0xFF050506); // Matches prototype #050506
  static const Color surface = Color(0xFF121214);
}

class RadioWahApp extends StatelessWidget {
  const RadioWahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RadioWahColors.deloitteGreen,
      brightness: Brightness.dark,
      primary: RadioWahColors.deloitteGreen,
      surface: RadioWahColors.surface,
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioAppState()),
        ChangeNotifierProvider(create: (_) {
          final controller = RadioPlayerController();
          controller.init();
          return controller;
        }),
      ],
      child: MaterialApp(
        title: 'Radio WAH',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: RadioWahColors.black,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: RadioWahColors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: RadioWahColors.black,
            selectedItemColor: RadioWahColors.deloitteGreen,
            unselectedItemColor: Color(0xFF8E8E94),
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    const screens = [
      PlayerScreen(),
      ScheduleScreen(),
      DiscoverScreen(),
      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: appState.currentNavIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF050506),
          border: Border(top: BorderSide(color: Color(0xFF1F1F23), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: appState.currentNavIndex,
          onTap: (index) {
            if (index == 2 && !RadioAppState.enableDiscoverTab) return;
            if (index == 3 && !RadioAppState.enableFavoritesTab) return;
            if (index == 4 && !RadioAppState.enableProfileTab) return;
            appState.setNavIndex(index);
          },
          backgroundColor: const Color(0xFF050506),
          selectedItemColor: const Color(0xFFC4D600),
          unselectedItemColor: const Color(0xFF8E8E94),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.radio),
              label: 'Live',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Palinsesto',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
                color: RadioAppState.enableDiscoverTab ? null : const Color(0xFF3A3A3C),
              ),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_border,
                color: RadioAppState.enableFavoritesTab ? null : const Color(0xFF3A3A3C),
              ),
              label: 'Preferiti',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color: RadioAppState.enableProfileTab ? null : const Color(0xFF3A3A3C),
              ),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
