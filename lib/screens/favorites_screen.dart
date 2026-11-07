import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import 'notifications_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    final favs = appState.favs;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preferiti',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  if (RadioAppState.showNotifications)
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'I programmi che salvi con il cuore. Ti avvisiamo 5 minuti prima di ogni diretta.',
                style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8), height: 1.3),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: favs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF3A3A40)),
                              ),
                              child: const Icon(Icons.favorite_border, color: Color(0xFFC4D600), size: 36),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ancora nessun preferito',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tocca il cuore su un programma: lo trovi qui e ti avvisiamo quando va in onda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Color(0xFFA3A3A8), height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4F4F2),
                                foregroundColor: const Color(0xFF050506),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              ),
                              onPressed: () => appState.setNavIndex(1), // Palinsesto
                              child: const Text('Sfoglia il palinsesto', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        Text(
                          '${favs.length} PROGRAMMI · IN ORDINE DI DIRETTA',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8)),
                        ),
                        const SizedBox(height: 12),
                        ...favs.map((id) {
                          final hasAlert = appState.hasAlert(id);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121214),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    color: const Color(0xFF1C1C1F),
                                    child: const Icon(Icons.radio, color: Color(0xFFC4D600)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        id.toUpperCase(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'In onda domani · 10:00',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF3EFAC5)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        hasAlert ? 'Avviso attivo' : 'Avviso disattivato',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E94)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(hasAlert ? Icons.notifications : Icons.notifications_none, color: hasAlert ? Colors.white : const Color(0xFF76767C)),
                                  onPressed: () => appState.toggleAlert(id),
                                ),
                                if (RadioAppState.showFavoriteIcon)
                                  IconButton(
                                    icon: const Icon(Icons.favorite, color: Color(0xFFC4D600)),
                                    onPressed: () => appState.toggleFav(id),
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
