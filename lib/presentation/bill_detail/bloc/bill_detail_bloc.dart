import 'package:bill_mate/data/bill_repository/bll_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/hive_fn.dart';
import 'bill_detail_event.dart';
import 'bill_detail_state.dart';

class BillDetailBloc extends Bloc<BillDetailEvent, BillDetailState> {
  BillRepository billRepository = BillRepository(HiveFn());
  BillDetailBloc() : super(InitialBillDetail()) {
    on<LoadBillEvent>((e, emit) => emit(LoadedBillDetail(e.bill)));
    on<MarkPaidEvent>(_onMarkPaid);
    on<DeleteBillEvent>(_onDelete);
    on<UpdateBillEvent>(_onUpdate);
  }

  Future<void> _onMarkPaid(MarkPaidEvent event,Emitter <BillDetailState> emit)async{

    try{
      emit(LoadingBillDetail());

      await billRepository.markPaidToggle(event.bill);
      emit(BillDetailSuccess());


    }catch(e){
      emit(ErrorBillDetail(e.toString()));
    }

  }
  Future<void> _onDelete(DeleteBillEvent event,Emitter <BillDetailState> emit)async{
    try{
      emit(LoadingBillDetail());
      await billRepository.deleteBill(event.bill);
      emit(BillDetailSuccess());

    }catch(e)
{
  emit(ErrorBillDetail(e.toString()));
}
  }

  Future<void> _onUpdate(UpdateBillEvent event,Emitter <BillDetailState> emit)async{
    try{
      emit(LoadingBillDetail());
      await billRepository.updateBill(event.bill);
    }catch(e)
    {
      emit(ErrorBillDetail(e.toString()));
    }
  }

}