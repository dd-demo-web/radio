class ScheduleItem {
  final String hourStart;
  final String hourEnd;
  final String title;
  final String subtitle;
  final String? image;
  final String? date;

  ScheduleItem({
    required this.hourStart,
    required this.hourEnd,
    required this.title,
    required this.subtitle,
    this.image,
    this.date,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      hourStart: (json['hour_start'] ?? '').toString(),
      hourEnd: (json['hour_end'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      image: json['thumbnail']?.toString(),
      date: json['date']?.toString(),
    );
  }
}

class WeeklySchedule {
  final Map<String, List<ScheduleItem>> days;

  WeeklySchedule({required this.days});

  static const List<String> dayOrder = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? {};
    final daysJson = result['days'] as Map<String, dynamic>? ?? {};
    final days = <String, List<ScheduleItem>>{};
    daysJson.forEach((key, value) {
      if (value is List) {
        days[key] = value
            .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
    return WeeklySchedule(days: days);
  }
}
