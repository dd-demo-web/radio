import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/player_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/info_screen.dart';
import 'services/carplay_bridge.dart';
import 'services/radio_audio_handler.dart';
import 'services/radio_player_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Audio e stato del live nascono qui, non dentro un widget: su iOS il motore
  // parte anche quando l'app viene aperta solo da CarPlay, su Android quando la
  // apre Android Auto, e in quei casi non c'è nessuna UI da costruire.
  final audioHandler = await initRadioAudio();
  final controller = RadioPlayerController(audioHandler)..start();
  CarPlayBridge.attach(controller);

  runApp(RadioWahApp(controller: controller));

  // Il primo frame arriva solo quando la UI è davvero sullo schermo:
  // è lì che parte l'autoplay (sul web può essere bloccato dal browser).
  WidgetsBinding.instance.addPostFrameCallback((_) => controller.autoplayOnce());
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
  const RadioWahApp({super.key, required this.controller});

  final RadioPlayerController controller;

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
        ChangeNotifierProvider.value(value: controller),
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
      final foreground = isSelected
          ? const Color(0xFFF4F4F2)
          : const Color(0xFFB4B4BA);

      return SizedBox(
        width: 84,
        child: Semantics(
          button: true,
          selected: isSelected,
          label: item.label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () => appState.setNavIndex(index),
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
                        color: isSelected
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
          child: IndexedStack(
            index: appState.currentNavIndex,
            children: screens,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < navItems.length; i++)
                          if (navItems[i].enabled) navigationItem(i),
                      ],
                    ),
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
