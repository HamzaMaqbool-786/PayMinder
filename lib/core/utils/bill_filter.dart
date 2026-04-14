import 'package:bill_mate/core/utils/date_formatter.dart';
import 'package:bill_mate/data/models/bill_model.dart';

import '../../domain/entities/bill_groups.dart';

class BillFilter {
  static List<BillModel> overDueBills(List<BillModel> bills) {
    return bills
        .where(
            (bill) => !bill.isPaid && DateFormatter.daysUntil(bill.dueDate) < 0)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<BillModel> upComingBills(List<BillModel> bills) {
    return bills
        .where(
            (bill) => !bill.isPaid && DateFormatter.daysUntil(bill.dueDate) > 3)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<BillModel> paidBills(List<BillModel> bills) {
    return bills.where((bill) => bill.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<BillModel> dueSoon(List<BillModel> bills) {
    return bills.where((bill) {
      if (bill.isPaid) return false;

      final days = DateFormatter.daysUntil(bill.dueDate); // use calendar days

      return days >= 0 && days <= 3; // within next 3 calendar days
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // ✅ Group all bills
  static BillGroups groupBills(List<BillModel> bills) => BillGroups(
        overdue: overDueBills(bills),
        dueSoon: dueSoon(bills),
        upcoming: upComingBills(bills),
        paid: paidBills(bills),
      );
}
