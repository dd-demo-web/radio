import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import 'info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    final favCount = appState.favs.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF050506),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 44),
                  Text('Profilo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'LF',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF050506)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Laura Fontana', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Marketing · sede di Milano', style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8))),
                          SizedBox(height: 2),
                          Text('Dati dal tuo account aziendale', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E94))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Grid
                  Row(
                    children: [
                      _statCard('14 h', 'ascoltate a ottobre'),
                      const SizedBox(width: 8),
                      _statCard('$favCount', 'programmi preferiti'),
                      const SizedBox(width: 8),
                      _statCard('37', 'dirette seguite'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('NOTIFICHE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8))),
                  const SizedBox(height: 8),
                  _prefRow(
                    'Avvisi prima delle dirette',
                    '5 minuti prima, solo per i preferiti',
                    appState.getPref('live'),
                    () => appState.togglePref('live'),
                  ),
                  _prefRow(
                    'Nuovi mixtape',
                    'Quando la redazione pubblica un mood',
                    appState.getPref('mix'),
                    () => appState.togglePref('mix'),
                  ),
                  _prefRow(
                    'Alta qualità solo in Wi-Fi',
                    'Risparmi dati quando sei fuori ufficio',
                    appState.getPref('wifi'),
                    () => appState.togglePref('wifi'),
                  ),
                  const SizedBox(height: 24),
                  const Text('RADIO WAH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8))),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('La redazione e i contatti', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoScreen())),
                  ),
                  const Divider(color: Color(0xFF1F1F23), height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Domande frequenti', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoScreen(openFaq: true))),
                  ),
                  const Divider(color: Color(0xFF1F1F23), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Qualità audio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('Alta · 320 kbps', style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8))),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1F1F23), height: 1),
                  const SizedBox(height: 16),
                  TextButton(
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disconnesso da Radio WAH')));
                    },
                    child: const Text('Esci da Radio WAH', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFFF6B5E))),
                  ),
                  const SizedBox(height: 12),
                  const Text('v1.0 · music by humans, for humans', style: TextStyle(fontSize: 11, color: Color(0xFF76767C))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFA3A3A8), height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _prefRow(String title, String subtitle, bool value, VoidCallback onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFFA3A3A8))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF050506),
            activeTrackColor: const Color(0xFFC4D600),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}
