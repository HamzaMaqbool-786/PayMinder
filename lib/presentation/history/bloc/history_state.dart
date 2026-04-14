import '../../../data/models/bill_model.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryLoaded extends HistoryState {
  final List<BillModel> bills;        // filtered bills shown in list
  final List<DateTime> availableMonths; // for the month filter chips
  final DateTime? selectedMonth;      // currently selected month (null = All)
  final double totalPaid;             // total for selected month or all

  HistoryLoaded({
    required this.bills,
    required this.availableMonths,
    required this.selectedMonth,
    required this.totalPaid,
  });
}