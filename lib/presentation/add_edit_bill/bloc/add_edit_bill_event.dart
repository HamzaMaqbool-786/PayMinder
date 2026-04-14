import 'package:image_picker/image_picker.dart';
import '../../../data/models/bill_model.dart';

abstract class BillFormEvent {}

class SaveBillEvent extends BillFormEvent {
  final BillModel bill;
  final bool isEdit;
  SaveBillEvent({required this.bill, required this.isEdit});
}

class PickImageEvent extends BillFormEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}

class RemoveImageEvent extends BillFormEvent {}