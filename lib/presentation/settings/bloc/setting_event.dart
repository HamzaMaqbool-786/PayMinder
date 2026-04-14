abstract class SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}

class ToggleReminderEvent extends SettingsEvent {
  final bool value;
  ToggleReminderEvent(this.value);
}

class ToggleAlarmSoundEvent extends SettingsEvent {
  final bool value;
  ToggleAlarmSoundEvent(this.value);
}

class ToggleVibrationEvent extends SettingsEvent {
  final bool value;
  ToggleVibrationEvent(this.value);
}

class ChangeDefaultRemindEvent extends SettingsEvent {
  final String value;
  ChangeDefaultRemindEvent(this.value);
}

class ClearDataEvent extends SettingsEvent {}