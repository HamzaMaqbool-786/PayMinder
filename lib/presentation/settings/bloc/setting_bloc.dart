import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/hive_fn.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/setting.dart';
import '../../../services/alarm_service.dart';
import '../../../services/notification_service.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {

  final HiveFn hive = HiveFn();

  late SettingsModel settings;

  SettingsBloc() : super(SettingsInitial()) {

    // ── Load ────────────────────────────────────────────────
    on<LoadSettingsEvent>((event, emit) {
      settings = hive.loadSettings(); // ← load from Hive
      emit(SettingsLoaded(settings));
    });

    // ── Reminders toggle ────────────────────────────────────
    on<ToggleReminderEvent>((event, emit) async {
      settings = settings.copyWith(reminders: event.value);
      await hive.saveSettings(settings); // ← persist

      if (!event.value) {
        // User turned OFF reminders — cancel all notifications
        await NotificationService.instance.cancelAll();
      } else {
        // User turned ON — reschedule for all unpaid bills
        await _rescheduleNotifications();
      }

      emit(SettingsLoaded(settings));
    });

    // ── Alarm Sound toggle ──────────────────────────────────
    on<ToggleAlarmSoundEvent>((event, emit) async {
      settings = settings.copyWith(alarmSound: event.value);
      await hive.saveSettings(settings); // ← persist

      if (!event.value) {
        // User turned OFF alarm — cancel all alarms
        await AlarmService.instance.cancelAll();
      } else {
        // User turned ON — reschedule for all unpaid bills
        await _rescheduleAlarms();
      }

      emit(SettingsLoaded(settings));
    });

    // ── Vibration toggle ────────────────────────────────────
    on<ToggleVibrationEvent>((event, emit) async {
      settings = settings.copyWith(vibration: event.value);
      await hive.saveSettings(settings); // ← persist
      // Reschedule alarms with updated vibration setting
      await _rescheduleAlarms();
      emit(SettingsLoaded(settings));
    });

    // ── Default Remind ──────────────────────────────────────
    on<ChangeDefaultRemindEvent>((event, emit) async {
      settings = settings.copyWith(defaultRemind: event.value);
      await hive.saveSettings(settings); // ← persist
      emit(SettingsLoaded(settings));
    });

    // ── Clear Data ──────────────────────────────────────────
    on<ClearDataEvent>((event, emit) async {
      // Cancel everything first
      await AlarmService.instance.cancelAll();
      await NotificationService.instance.cancelAll();

      // Clear Hive
      await hive.clearAllBills();

      emit(SettingsLoaded(settings));
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Future<void> _rescheduleAlarms() async {
    final bills = await hive.loadBills();
    final unpaid = bills.where((b) => !b.isPaid).toList();

    await AlarmService.instance.cancelAll();

    if (settings.alarmSound) {
      for (final bill in unpaid) {
        await AlarmService.instance.scheduleAlarm(
          bill,
          vibrate: settings.vibration, // ← pass vibration setting
        );
      }
    }
  }
  Future<void> _rescheduleNotifications() async {
    final bills = await hive.loadBills();
    final unpaid = bills.where((b) => !b.isPaid).toList();

    await NotificationService.instance.cancelAll();

    if (settings.reminders) {
      for (final bill in unpaid) {
        await NotificationService.instance.scheduleReminder(bill);
      }
    }
  }
}