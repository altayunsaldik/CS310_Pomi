class AppSettings {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final double volume;
  final bool vibration;
  final bool notifications;

  const AppSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.volume = 0.7,
    this.vibration = true,
    this.notifications = true,
  });

  AppSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    double? volume,
    bool? vibration,
    bool? notifications,
  }) =>
      AppSettings(
        focusMinutes: focusMinutes ?? this.focusMinutes,
        shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
        longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
        sessionsBeforeLongBreak:
            sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
        volume: volume ?? this.volume,
        vibration: vibration ?? this.vibration,
        notifications: notifications ?? this.notifications,
      );

  factory AppSettings.fromMap(Map<String, dynamic>? m) {
    const d = AppSettings();
    if (m == null) return d;
    return AppSettings(
      focusMinutes: (m['focusMinutes'] as num?)?.toInt() ?? d.focusMinutes,
      shortBreakMinutes:
          (m['shortBreakMinutes'] as num?)?.toInt() ?? d.shortBreakMinutes,
      longBreakMinutes:
          (m['longBreakMinutes'] as num?)?.toInt() ?? d.longBreakMinutes,
      sessionsBeforeLongBreak: (m['sessionsBeforeLongBreak'] as num?)?.toInt() ??
          d.sessionsBeforeLongBreak,
      volume: (m['volume'] as num?)?.toDouble() ?? d.volume,
      vibration: (m['vibration'] as bool?) ?? d.vibration,
      notifications: (m['notifications'] as bool?) ?? d.notifications,
    );
  }

  Map<String, dynamic> toMap() => {
        'focusMinutes': focusMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        'volume': volume,
        'vibration': vibration,
        'notifications': notifications,
      };
}
