import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/hive_fn.dart';
import '../../../data/bill_repository/bll_repository.dart';
import 'add_edit_bill_event.dart';
import 'add_edit_bill_state.dart';

class BillFormBloc extends Bloc<BillFormEvent, BillFormState> {

  final BillRepository repo = BillRepository(HiveFn());
  String? currentPhotoPath;

  BillFormBloc({String? initialPhotoPath}) : super(BillFormInitial()) {
    currentPhotoPath = initialPhotoPath;

    on<SaveBillEvent>(_saveBill);
    on<PickImageEvent>(_pickImage);
    on<RemoveImageEvent>(_removeImage);
  }

  Future<void> _saveBill(
      SaveBillEvent event,
      Emitter<BillFormState> emit,
      ) async {
    final name = event.bill.name.trim();

    if (name.isEmpty) {
      emit(BillFormError('Bill name is required'));
      return;
    }

    if (event.bill.dueDate == null) {
      emit(BillFormError('Please select a due date'));
      return;
    }

    try {
      emit(BillFormLoading());
      if (event.isEdit) {
        await repo.updateBill(event.bill);
      } else {
        await repo.addBill(event.bill);
      }
      emit(BillFormSuccess());
    } catch (e) {
      emit(BillFormError(e.toString()));
    }
  }

  Future<void> _pickImage(
      PickImageEvent event,
      Emitter<BillFormState> emit,
      ) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: event.source,
        imageQuality: 80,
      );
      if (picked != null) {
        currentPhotoPath = picked.path;
        emit(BillFormUpdated(photoPath: currentPhotoPath));
      }
    } catch (e) {
      emit(BillFormError('Failed to pick image'));
    }
  }

  void _removeImage(
      RemoveImageEvent event,
      Emitter<BillFormState> emit,
      ) {
    currentPhotoPath = null;
    emit(BillFormUpdated(photoPath: null));
  }
}