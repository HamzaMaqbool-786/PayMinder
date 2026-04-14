import 'package:alarm/alarm.dart';
import '../data/models/bill_model.dart';

class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  Future<void> init() async => Alarm.init();


// TO this — accept vibrate param
    Future<void> scheduleAlarm(BillModel bill, {bool vibrate = true}) async {
      final alarmTime = DateTime(
        bill.dueDate.year, bill.dueDate.month, bill.dueDate.day, 20, 0,
      );
      if (alarmTime.isBefore(DateTime.now())) return;

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id:             bill.key,
          dateTime:       alarmTime,
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio:      true,
          vibrate:        vibrate, // ← use param instead of hardcoded true
          warningNotificationOnKill: true,
          notificationSettings: NotificationSettings(
            title:      'Bill Due Today!',
            body:       '${bill.name} — Rs ${bill.amount.toStringAsFixed(0)} is due now',
            stopButton: 'Dismiss',
          ),
        ),
      );
    }
  Future<void> cancelAlarm(int billKey) async => Alarm.stop(billKey);

  Future<void> cancelAll() async {
    final alarms = await Alarm.getAlarms();
    for (final a in alarms) {
      await Alarm.stop(a.id);
    }
  }

  // Alarm.getAlarms() is async — returns Future<List<AlarmSettings>>
  // so isAlarmSet must also be async and return Future<bool>
  Future<bool> isAlarmSet(int billKey) async {
    final alarms = await Alarm.getAlarms();
    return alarms.any((a) => a.id == billKey);
  }
}
