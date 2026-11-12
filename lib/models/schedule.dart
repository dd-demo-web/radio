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

  /// Minuti dalla mezzanotte di "HH:MM", o null se il formato non torna.
  static int? _minutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  /// Intervallo [inizio, fine) in minuti dalla mezzanotte del giorno del
  /// programma. Se finisce dopo mezzanotte (es. 23:00–01:00 o fine "00:00")
  /// la fine va oltre 1440.
  ({int start, int end})? get _range {
    final start = _minutes(hourStart);
    var end = _minutes(hourEnd);
    if (start == null || end == null) return null;
    if (end <= start) end += 24 * 60;
    return (start: start, end: end);
  }

  /// In onda al minuto [minuteOfDay] del giorno del programma
  /// (passa minuteOfDay + 1440 per controllare la coda dopo mezzanotte).
  bool isOnAirAt(int minuteOfDay) {
    final range = _range;
    return range != null && minuteOfDay >= range.start && minuteOfDay < range.end;
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

  /// Chiave del giorno (`mon`…`sun`) per una data.
  static String dayKey(DateTime date) => dayOrder[date.weekday - 1];

  List<ScheduleItem> itemsFor(DateTime date) => days[dayKey(date)] ?? const [];

  /// Programma in onda in [now]: cerca tra quelli di oggi e, per i programmi
  /// che passano la mezzanotte, tra quelli di ieri.
  ScheduleItem? onAirAt(DateTime now) {
    final minute = now.hour * 60 + now.minute;
    for (final item in itemsFor(now)) {
      if (item.isOnAirAt(minute)) return item;
    }
    final yesterday = now.subtract(const Duration(days: 1));
    for (final item in itemsFor(yesterday)) {
      if (item.isOnAirAt(minute + 24 * 60)) return item;
    }
    return null;
  }

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
