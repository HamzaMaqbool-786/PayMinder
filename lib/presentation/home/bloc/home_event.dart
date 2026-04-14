import '../../../data/models/bill_model.dart';

abstract class HomeEvent {}

class LoadBillsEvent extends HomeEvent {}

class DeleteBillEvent extends HomeEvent {
  final BillModel bill;

  DeleteBillEvent(this.bill);
}

class MarkBillPaidEvent extends HomeEvent {
  final BillModel bill;

  MarkBillPaidEvent(this.bill);
}