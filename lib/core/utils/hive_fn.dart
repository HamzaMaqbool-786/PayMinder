import 'package:bill_mate/core/constants/app_hive_keys.dart';
import 'package:bill_mate/data/models/bill_model.dart';
import 'package:hive/hive.dart';

import '../../data/models/setting.dart';

class HiveFn {

  final billBox = Hive.box<BillModel>(HiveKeys.billBox);

  Future<Box<BillModel>> openBillBox() async {

    // Insert mock data only first time
    if (billBox.isEmpty) {
      await billBox.addAll(mockBills);
    }

    return billBox;
  }

  Future<void> addBill(BillModel bill) async {
    await billBox.add(bill);
  }

  Future<List<BillModel>> loadBills() async {
    return billBox.values.toList();
  }

  Future<void> deleteBill(BillModel bill) async {
    await bill.delete();
  }

  Future<void> updateBill(BillModel bill) async {
    await bill.save();
  }

  Future<void> markPaidToggle(BillModel bill) async {
    bill.isPaid = !bill.isPaid;
    await bill.save();
  }
  Future<void> clearAllBills() async {
    final box = await Hive.openBox<BillModel>('bills');
    await box.clear();
  }

  Box get settingsBox => Hive.box(HiveKeys.settingsBox);

  SettingsModel loadSettings() {
    return SettingsModel(
      reminders:     settingsBox.get(HiveKeys.reminders,     defaultValue: true),
      alarmSound:    settingsBox.get(HiveKeys.alarmSound,    defaultValue: true),
      vibration:     settingsBox.get(HiveKeys.vibration,     defaultValue: false),
      defaultRemind: settingsBox.get(HiveKeys.defaultRemind, defaultValue: '1 day before'),
    );
  }

  Future<void> saveSettings(SettingsModel s) async {
    await settingsBox.put(HiveKeys.reminders,     s.reminders);
    await settingsBox.put(HiveKeys.alarmSound,    s.alarmSound);
    await settingsBox.put(HiveKeys.vibration,     s.vibration);
    await settingsBox.put(HiveKeys.defaultRemind, s.defaultRemind);
  }
}



final List<BillModel> mockBills = [
  BillModel(
    id: '1',
    name: 'Electricity Bill',
    amount: 120.50,
    dueDate: DateTime.now().subtract(const Duration(days: 2)), // overdue
    category: 'Utilities',
    isPaid: false,
    remindBefore: '1 day before',
    repeat: 'Monthly',
    photoPath: null,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  BillModel(
    id: '2',
    name: 'Water Bill',
    amount: 45.00,
    dueDate: DateTime.now().add(const Duration(days: 3)), // due soon
    category: 'Utilities',
    isPaid: false,
    remindBefore: '1 day before',
    repeat: 'Monthly',
    photoPath: null,
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
  BillModel(
    id: '3',
    name: 'Internet Bill',
    amount: 80.00,
    dueDate: DateTime.now().add(const Duration(days: 10)), // upcoming
    category: 'Internet',
    isPaid: false,
    remindBefore: '1 day before',
    repeat: 'Monthly',
    photoPath: null,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
  BillModel(
    id: '4',
    name: 'Gym Membership',
    amount: 60.00,
    dueDate: DateTime.now().subtract(const Duration(days: 1)), // paid
    category: 'Health',
    isPaid:false,
    remindBefore: '1 day before',
    repeat: 'Monthly',
    photoPath: null,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
];
