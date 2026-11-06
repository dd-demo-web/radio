import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import 'info_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    final unread = appState.unreadNotifications;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF050506),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('Notifiche', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: unread ? () => appState.markNotificationsRead() : null,
                    child: Text(
                      'Segna lette',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: unread ? const Color(0xFFC4D600) : const Color(0xFF5A5A60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'OGGI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8)),
                  ),
                  const SizedBox(height: 8),
                  // Notification item 1
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: unread ? const Color(0xFF121214) : Colors.transparent,
                      borderRadius: BorderRadius.circular(unread ? 16 : 0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.radio, color: Color(0xFFC4D600)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tra 5 minuti in onda: Funky Reload', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  const Text('12:25', style: TextStyle(fontSize: 11, color: Color(0xFFA3A3A8))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('Funk, soul e disco per la pausa pranzo: alza il volume.', style: TextStyle(fontSize: 14, color: Color(0xFFC9C9CE), height: 1.3)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC4D600),
                                      foregroundColor: const Color(0xFF050506),
                                      minimumSize: const Size(0, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                    onPressed: () {
                                      appState.setNavIndex(0);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Vai al live', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 36),
                                      side: const BorderSide(color: Color(0xFF3A3A40)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                    onPressed: () {
                                      appState.setNavIndex(3); // Favorites
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Gestisci avviso', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF33F0FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'QUESTA SETTIMANA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8)),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.music_note, color: Color(0xFFC4D600)),
                    ),
                    title: const Text('Nuovo mixtape: Pop Therapy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Ritornelli che fanno bene, scelti dalla redazione.', style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8))),
                    trailing: const Text('Lun', style: TextStyle(fontSize: 11, color: Color(0xFFA3A3A8))),
                  ),
                  const Divider(color: Color(0xFF1F1F23)),
                  const SizedBox(height: 12),
                  const Text(
                    'Ricevi avvisi solo per i programmi nei preferiti. Gestisci le notifiche nel profilo.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8E8E94), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
