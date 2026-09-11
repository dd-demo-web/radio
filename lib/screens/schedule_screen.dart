import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../services/radio_api_service.dart';

const Map<String, String> _dayLabels = {
  'mon': 'Lunedì',
  'tue': 'Martedì',
  'wed': 'Mercoledì',
  'thu': 'Giovedì',
  'fri': 'Venerdì',
  'sat': 'Sabato',
  'sun': 'Domenica',
};

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final RadioApiService _apiService = RadioApiService();
  late Future<WeeklySchedule> _future;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchWeeklySchedule();
    _tabController = TabController(
      length: WeeklySchedule.dayOrder.length,
      vsync: this,
      initialIndex: (DateTime.now().weekday - 1).clamp(0, 6),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palinsesto settimanale'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: WeeklySchedule.dayOrder
              .map((d) => Tab(text: _dayLabels[d] ?? d))
              .toList(),
        ),
      ),
      body: FutureBuilder<WeeklySchedule>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossibile caricare il palinsesto.\n${snapshot.error ?? ''}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final schedule = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: WeeklySchedule.dayOrder.map((day) {
              final items = schedule.days[day] ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('Nessun programma'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: item.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.radio),
                            ),
                          )
                        : const Icon(Icons.radio),
                    title: Text(item.title),
                    subtitle: item.subtitle.isNotEmpty
                        ? Text(item.subtitle)
                        : null,
                    trailing: Text('${item.hourStart}\n${item.hourEnd}'),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
