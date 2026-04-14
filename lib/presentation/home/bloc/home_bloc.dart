import 'package:bill_mate/core/utils/bill_filter.dart';
import 'package:bill_mate/core/utils/hive_fn.dart';
import 'package:bill_mate/data/bill_repository/bll_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/bill_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  BillRepository billRepository = BillRepository(HiveFn());

  HomeBloc() : super(HomeInitial()) {
    on<LoadBillsEvent>(_onLoad);
    on<MarkBillPaidEvent>(_markPaid);
    on<DeleteBillEvent>(_deleteBill);
  }

  Future<void> _markPaid(MarkBillPaidEvent e, Emitter<HomeState> emit) async {
    try {
      await billRepository.markPaidToggle(e.bill);
      add(LoadBillsEvent());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _deleteBill(DeleteBillEvent e, Emitter<HomeState> emit) async {
    try {
      await billRepository.deleteBill(e.bill);
      add(LoadBillsEvent());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoad(LoadBillsEvent e, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // simulate loading

      final List<BillModel> bills = await billRepository.loadBills();
      final grouped = BillFilter.groupBills(bills);
      emit(HomeLoaded(
        grouped: grouped
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}

