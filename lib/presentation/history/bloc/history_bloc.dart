import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/hive_fn.dart';
import '../../../data/bill_repository/bll_repository.dart';
import '../../../data/models/bill_model.dart';
import '../../../core/utils/bill_filter.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {

  final BillRepository repo = BillRepository(HiveFn());

  // Keep all paid bills in memory so filtering doesn't re-fetch
  List<BillModel> _allPaidBills = [];

  HistoryBloc() : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoad);
    on<FilterMonthEvent>(_onFilter);
  }

  Future<void> _onLoad(
      LoadHistoryEvent event,
      Emitter<HistoryState> emit,
      ) async {
    try {
      emit(HistoryLoading());

      final all = await repo.loadBills();

      // Use BillFilter to get only paid bills
      _allPaidBills = BillFilter.paidBills(all);

      emit(_buildLoaded(selectedMonth: null));

    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  void _onFilter(
      FilterMonthEvent event,
      Emitter<HistoryState> emit,
      ) {
    emit(_buildLoaded(selectedMonth: event.month));
  }

  // ── Helper: build HistoryLoaded from current _allPaidBills ───────────────

  HistoryLoaded _buildLoaded({required DateTime? selectedMonth}) {
    // Filter bills by selected month or show all
    final filtered = selectedMonth == null
        ? _allPaidBills
        : _allPaidBills.where((b) =>
    b.dueDate.year == selectedMonth.year &&
        b.dueDate.month == selectedMonth.month,
    ).toList();

    // Total amount of filtered bills
    final total = filtered.fold<double>(0, (sum, b) => sum + b.amount);

    // Extract unique months from all paid bills for the filter chips
    final months = _availableMonths(_allPaidBills);

    return HistoryLoaded(
      bills:           filtered,
      availableMonths: months,
      selectedMonth:   selectedMonth,
      totalPaid:       total,
    );
  }

  // ── Extract unique year+month list sorted latest first ───────────────────

  List<DateTime> _availableMonths(List<BillModel> bills) {
    final months = bills
        .map((b) => DateTime(b.dueDate.year, b.dueDate.month))
        .toSet()  // ← Set handles uniqueness automatically
        .toList()
      ..sort((a, b) => b.compareTo(a)); // latest first

    return months;
  }}