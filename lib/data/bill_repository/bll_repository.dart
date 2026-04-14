import 'package:uuid/uuid.dart';
import '../../core/utils/hive_fn.dart';
import '../models/bill_model.dart';
import '../../services/alarm_service.dart';
import '../../services/notification_service.dart';

class BillRepository {

  final HiveFn hiveFn;

  BillRepository(this.hiveFn);

  // ── Add Bill ───────────────────────────────────────────────────────────

  Future<void> addBill(BillModel bill) async {
    await hiveFn.addBill(bill);

    final settings = hiveFn.loadSettings();

    if (settings.reminders) {
      await NotificationService.instance.scheduleReminder(bill);
    }
    if (settings.alarmSound) {
      await AlarmService.instance.scheduleAlarm(
        bill,
        vibrate: settings.vibration,
      );
    }
  }

  // ── Update Bill ────────────────────────────────────────────────────────

  Future<void> updateBill(BillModel bill) async {
    await AlarmService.instance.cancelAlarm(bill.key);
    await NotificationService.instance.cancelReminder(bill.key);

    await hiveFn.updateBill(bill);

    final settings = hiveFn.loadSettings();

    if (settings.alarmSound) {
      await AlarmService.instance.scheduleAlarm(
        bill,
        vibrate: settings.vibration,
      );
    }
    if (settings.reminders) {
      await NotificationService.instance.scheduleReminder(bill);
    }
  }

  // ── Load Bills ─────────────────────────────────────────────────────────

  Future<List<BillModel>> loadBills() async {
    return hiveFn.loadBills();
  }

  // ── Delete Bill ────────────────────────────────────────────────────────

  Future<void> deleteBill(BillModel bill) async {
    await AlarmService.instance.cancelAlarm(bill.key);
    await NotificationService.instance.cancelReminder(bill.key);
    await hiveFn.deleteBill(bill);
  }

  // ── Mark Paid ──────────────────────────────────────────────────────────

  Future<void> markPaidToggle(BillModel bill) async {
    await hiveFn.markPaidToggle(bill);

    // After toggle, bill.isPaid is now true
    // Create next bill only when marking AS paid (not unpaid)
    if (bill.isPaid && bill.repeat != 'None') {
      final nextBill = _createNextBill(bill);
      if (nextBill != null) {
        await addBill(nextBill); // handles alarm + notification too
      }
    }
  }

  // ── Clear All ──────────────────────────────────────────────────────────

  Future<void> clearAllBills() async {
    await hiveFn.clearAllBills();
  }

  // ── Repeat Logic ───────────────────────────────────────────────────────

  BillModel? _createNextBill(BillModel bill) {
    DateTime nextDate;

    switch (bill.repeat) {
      case 'Monthly':
        nextDate = _safeNextMonth(bill.dueDate); // ✅ assign return value
        break;
      case 'Yearly':
        nextDate = DateTime(                     // ✅ correct yearly logic
          bill.dueDate.year + 1,
          bill.dueDate.month,
          bill.dueDate.day,
        );
        break;
      default:
        return null;
    }

    return BillModel(
      id:           const Uuid().v4(),
      name:         bill.name,
      amount:       bill.amount,
      dueDate:      nextDate,
      category:     bill.category,
      isPaid:       false,
      remindBefore: bill.remindBefore,
      repeat:       bill.repeat,
      photoPath:    bill.photoPath,
      createdAt:    DateTime.now(),
    );
  }

  // ── Safe Month Helper ──────────────────────────────────────────────────
  // Handles edge case: Jan 31 + 1 month should be Feb 28, not Mar 2

  DateTime _safeNextMonth(DateTime date) {
    final lastDayOfNextMonth = DateTime(date.year, date.month + 2, 0).day;
    final day = date.day.clamp(1, lastDayOfNextMonth);
    return DateTime(date.year, date.month + 1, day);
  }
}