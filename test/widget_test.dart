import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/utils/format.dart';

void main() {
  test('formatMinutes', () {
    expect(formatMinutes(50), '50 min');
    expect(formatMinutes(350), '5 h 50 min');
    expect(formatMinutes(120), '2 h');
  });

  test('formatClock', () {
    expect(formatClock(1122), '18:42');
    expect(formatClock(5), '00:05');
  });

  test('sessionsAndTime', () {
    expect(sessionsAndTime(0, 0), 'No sessions yet');
    expect(sessionsAndTime(1, 25), '1 session, 25 min');
    expect(sessionsAndTime(2, 50), '2 sessions, 50 min');
  });
}
