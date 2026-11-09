import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/player_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/info_screen.dart';
import 'services/radio_player_controller.dart';

void main() {
  runApp(const RadioWahApp());
}

class RadioWahColors {
  RadioWahColors._();

  static const Color deloitteGreen = Color(
    0xFFC4D600,
  ); // Matches prototype #C4D600
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
        ChangeNotifierProvider(
          create: (_) {
            final controller = RadioPlayerController();
            controller.init();
            return controller;
          },
        ),
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
      InfoScreen(),
    ];
    const navBarHeight = 96.0;
    final navItems = [
      (label: 'Live', icon: Icons.radio, enabled: true),
      (label: 'Palinsesto', icon: Icons.calendar_today, enabled: true),
      (
        label: 'Esplora',
        icon: Icons.explore,
        enabled: RadioAppState.enableDiscoverTab,
      ),
      (
        label: 'Info',
        icon: Icons.info_outline,
        enabled: RadioAppState.enableInfoTab,
      ),
    ];

    Widget navigationItem(int index) {
      final item = navItems[index];
      final isSelected = appState.currentNavIndex == index;
      final foreground = !item.enabled
          ? const Color(0xFF48484D)
          : isSelected
          ? const Color(0xFFF4F4F2)
          : const Color(0xFFB4B4BA);

      return Expanded(
        child: Semantics(
          button: true,
          enabled: item.enabled,
          selected: isSelected,
          label: item.label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: item.enabled ? () => appState.setNavIndex(index) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isSelected && item.enabled
                            ? const Color(0xFFC4D600)
                            : foreground,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    return Stack(
      children: [
        MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(
              bottom: mediaQuery.padding.bottom + navBarHeight,
            ),
          ),
          child: IndexedStack(index: appState.currentNavIndex, children: screens),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x94202024),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(navItems.length, navigationItem),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
