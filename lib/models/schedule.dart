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

  static String _sanitizeText(String text) {
    return text
        .replaceAll('\u2018', "'") // Left single quotation mark
        .replaceAll('\u2019', "'") // Right single quotation mark
        .replaceAll('\u201C', '"') // Left double quotation mark
        .replaceAll('\u201D', '"') // Right double quotation mark
        .replaceAll('\u2026', '...') // Ellipsis
        .replaceAll('\u2013', '-') // En dash
        .replaceAll('\u2014', '-'); // Em dash
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      hourStart: (json['hour_start'] ?? json['start'] ?? '').toString(),
      hourEnd: (json['hour_end'] ?? json['end'] ?? '').toString(),
      title: _sanitizeText((json['title'] ?? json['name'] ?? '').toString()),
      subtitle: _sanitizeText((json['subtitle'] ?? json['description'] ?? '').toString()),
      image: json['thumbnail']?.toString() ?? json['image']?.toString(),
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
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final daysJson = result['days'] as Map<String, dynamic>? ?? result;
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
