import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/models/bill_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId   = 'bill_reminder_channel';
  static const String _channelName = 'Bill Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId, _channelName, importance: Importance.high,
        ));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminder(BillModel bill) async {
    final int days = _toDays(bill.remindBefore);
    final DateTime notifyAt = DateTime(
      bill.dueDate.year, bill.dueDate.month, bill.dueDate.day - days, 9, 0,
    );
    if (notifyAt.isBefore(DateTime.now())) return;

    final String title = days == 0
        ? 'Bill due today!'
        : 'Bill due in $days day${days == 1 ? "" : "s"}!';
    final String body =
        '${bill.name} — Rs ${bill.amount.toStringAsFixed(0)} payment coming up';

    await _plugin.zonedSchedule(
      bill.key,
      title,
      body,
      tz.TZDateTime.from(notifyAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int billKey) async => _plugin.cancel(billKey);
  Future<void> cancelAll() async => _plugin.cancelAll();

  int _toDays(String remind) => switch (remind) {
    '1 day before'  => 1,
    '3 days before' => 3,
    '1 week before' => 7,
    'On due date'   => 0,
    _               => 1,
  };
}
