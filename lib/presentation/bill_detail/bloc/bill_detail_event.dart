import 'package:bill_mate/data/models/bill_model.dart';

abstract class BillDetailEvent {}

class LoadBillEvent extends BillDetailEvent{
  final BillModel bill;
  LoadBillEvent(this.bill);
}

class DeleteBillEvent extends BillDetailEvent{
  final BillModel bill;
  DeleteBillEvent(this.bill);
}
class MarkPaidEvent extends BillDetailEvent{
  final BillModel bill;
  MarkPaidEvent(this.bill);
}
class UpdateBillEvent extends BillDetailEvent{
  final BillModel bill;
  UpdateBillEvent(this.bill);
}