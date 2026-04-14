import '../../../data/models/bill_model.dart';

abstract class BillDetailState {}

class InitialBillDetail extends BillDetailState {}

class LoadingBillDetail extends BillDetailState {}
class BillDetailSuccess extends BillDetailState {}


class ErrorBillDetail extends BillDetailState {
  final String message;
  ErrorBillDetail(this.message);
}

class LoadedBillDetail extends BillDetailState {
  final BillModel bill;

  LoadedBillDetail(this.bill);
}
