class SettingsModel {
  final bool reminders;
  final bool alarmSound;
  final bool vibration;
  final String defaultRemind;

  SettingsModel({
    required this.reminders,
    required this.alarmSound,
    required this.vibration,
    required this.defaultRemind,
  });

  SettingsModel copyWith({
    bool? reminders,
    bool? alarmSound,
    bool? vibration,
    String? defaultRemind,
  }) {
    return SettingsModel(
      reminders:     reminders     ?? this.reminders,
      alarmSound:    alarmSound    ?? this.alarmSound,
      vibration:     vibration     ?? this.vibration,
      defaultRemind: defaultRemind ?? this.defaultRemind,
    );
  }
}