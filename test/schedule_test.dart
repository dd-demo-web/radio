import 'package:flutter_test/flutter_test.dart';
import 'package:radio_wah/models/schedule.dart';

ScheduleItem show(String start, String end, String title) =>
    ScheduleItem(hourStart: start, hourEnd: end, title: title, subtitle: '');

void main() {
  // 2026-11-10 è martedì ('tue'), 2026-11-11 mercoledì ('wed').
  final schedule = WeeklySchedule(
    days: {
      'tue': [show('20:00', '23:00', 'Sera'), show('23:00', '01:00', 'Notte')],
      'wed': [
        show('08:30', '10:00', 'Moka'),
        show('10:00', '12:00', 'Fresh Sounds'),
        show('22:00', '00:00', 'Chiusura'),
      ],
    },
  );

  test('programma di giorno', () {
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 9, 15))?.title, 'Moka');
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 10, 0))?.title, 'Fresh Sounds');
  });

  test('buco nel palinsesto', () {
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 14, 0)), isNull);
  });

  test('fine a mezzanotte ("00:00")', () {
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 23, 59))?.title, 'Chiusura');
  });

  test('programma di ieri che passa la mezzanotte', () {
    expect(schedule.onAirAt(DateTime(2026, 11, 10, 23, 30))?.title, 'Notte');
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 0, 30))?.title, 'Notte');
    expect(schedule.onAirAt(DateTime(2026, 11, 11, 1, 0)), isNull);
  });
}
