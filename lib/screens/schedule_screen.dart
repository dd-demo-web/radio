import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/schedule.dart';
import '../services/radio_api_service.dart';
import '../widgets/mini_player.dart';
import 'notifications_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final RadioApiService _apiService = RadioApiService();
  late Future<WeeklySchedule> _future;
  int _selectedDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchWeeklySchedule();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getDaysOfWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const shortLabels = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM'];

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return {
        'short': shortLabels[i],
        'num': day.day.toString(),
      };
    });
  }

  bool _isItemOnAir(ScheduleItem item, int dayIndex, int todayIndex) {
    if (dayIndex != todayIndex) return false;
    try {
      final now = TimeOfDay.now();
      final startParts = item.hourStart.split(':');
      final endParts = item.hourEnd.split(':');
      if (startParts.length < 2 || endParts.length < 2) return false;

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final nowMinutes = now.hour * 60 + now.minute;

      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    final daysData = _getDaysOfWeek();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Palinsesto',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  Row(
                    children: [
                      if (RadioAppState.showSearch)
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        )
                      else
                        const SizedBox(width: 48),
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
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Palinsesto settimanale · dirette dalle 8:30 alle 18:30',
                style: TextStyle(fontSize: 12, color: Color(0xFFA3A3A8)),
              ),
            ),
            const SizedBox(height: 16),
            // Day selector tabs (Dynamic dates)
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: daysData.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  final isToday = index == todayIndex;
                  final day = daysData[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      width: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF4F4F2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFF4F4F2) : const Color(0xFF2A2A2E),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isToday ? 'OGGI' : day['short']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: isSelected ? const Color(0xFF050506) : (index > 4 ? const Color(0xFF76767C) : const Color(0xFFF4F4F2)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day['num']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? const Color(0xFF050506) : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? (isSelected ? const Color(0xFF050506) : const Color(0xFFC4D600))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Schedule list
            Expanded(
              child: FutureBuilder<WeeklySchedule>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text('Impossibile caricare il palinsesto.'),
                    );
                  }
                  final schedule = snapshot.data!;
                  final dayKey = WeeklySchedule.dayOrder.length > _selectedDayIndex
                      ? WeeklySchedule.dayOrder[_selectedDayIndex]
                      : '';
                  List<ScheduleItem> items = schedule.days[dayKey] ?? [];
                  if (items.isEmpty && schedule.days.isNotEmpty) {
                    final keys = schedule.days.keys.toList();
                    if (_selectedDayIndex < keys.length) {
                      items = schedule.days[keys[_selectedDayIndex]] ?? [];
                    } else {
                      items = schedule.days.values.first;
                    }
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Weekend in silenzio',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Lo studio riapre lunedì alle 8:30 con Moka. Intanto la musica non si ferma: i mixtape girano 24/7.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Color(0xFFA3A3A8), height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4F4F2),
                                foregroundColor: const Color(0xFF050506),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              ),
                              onPressed: () => appState.setNavIndex(2), // Discover
                              child: const Text('Apri i mixtape', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLive = _isItemOnAir(item, _selectedDayIndex, todayIndex);
                      final isFav = appState.isFav(item.title);

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isLive ? const Color(0xFF1A2A14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isLive ? Border.all(color: const Color(0xFFC4D600).withOpacity(0.55)) : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (isLive) {
                                    appState.setNavIndex(0);
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 44,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.hourStart,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            item.hourEnd,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E94)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.image != null
                                          ? Image.network(
                                              item.image!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 60,
                                                height: 60,
                                                color: const Color(0xFF1C1C1F),
                                                child: const Icon(Icons.radio, color: Color(0xFFC4D600)),
                                              ),
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              color: const Color(0xFF1C1C1F),
                                              child: const Icon(Icons.radio, color: Color(0xFFC4D600)),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (isLive)
                                            const Text(
                                              'IN ONDA ORA',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC4D600)),
                                            ),
                                          Text(
                                            item.title,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (item.subtitle.isNotEmpty)
                                            Text(
                                              item.subtitle,
                                              style: const TextStyle(fontSize: 13, color: Color(0xFFA3A3A8)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (RadioAppState.showFavoriteIcon)
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? const Color(0xFFC4D600) : const Color(0xFFA3A3A8),
                                ),
                                onPressed: () => appState.toggleFav(item.title),
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Mini player above bottom bar as seen in prototype
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}
