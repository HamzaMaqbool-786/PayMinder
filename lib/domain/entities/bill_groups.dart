import '../../data/models/bill_model.dart';

class BillGroups {
  final List<BillModel> overdue;
  final List<BillModel> dueSoon;
  final List<BillModel> upcoming;
  final List<BillModel> paid;

  const BillGroups({
    required this.overdue,
    required this.dueSoon,
    required this.upcoming,
    required this.paid,
  });

  double get totalDue =>
      [...overdue, ...dueSoon, ...upcoming].fold(0, (s, b) => s + b.amount);
  int get overdueCount => overdue.length;
  int get dueSoonCount => dueSoon.length;
  bool get isEmpty =>
      overdue.isEmpty && dueSoon.isEmpty && upcoming.isEmpty && paid.isEmpty;
}
