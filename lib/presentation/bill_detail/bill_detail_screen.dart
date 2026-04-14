import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/bill_status_helper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/bill_model.dart';
import '../../services/alarm_service.dart';
import '../add_edit_bill/add_bill_screen.dart';
import 'bloc/bill_detail_bloc.dart';
import 'bloc/bill_detail_event.dart';
import 'bloc/bill_detail_state.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bill = ModalRoute.of(context)!.settings.arguments as BillModel;
    return BlocProvider(
      create: (_) => BillDetailBloc()..add(LoadBillEvent(bill)),
      child: const _BillDetailView(),
    );
  }
}

class _BillDetailView extends StatelessWidget {
  const _BillDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<BillDetailBloc, BillDetailState>(
        listener: (ctx, state) {
          if (state is BillDetailSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('Done!'), backgroundColor: AppColors.paidText,
            ));
            Navigator.pop(ctx, true);
          }
          if (state is ErrorBillDetail) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.overdueText,
            ));
          }
        },
        builder: (ctx, state) {
          if (state is LoadedBillDetail) {
            return Scaffold(
              backgroundColor: AppColors.background,
              // ✅ FAB is here now — has access to state.bill
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.edit, color: AppColors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => AddBillScreen(bill: state.bill), // ✅ edit mode
                    ),
                  );
                  // Reload detail if bill was updated
                  if (result == true) {
                    ctx.read<BillDetailBloc>().add(LoadBillEvent(state.bill));
                  }
                },
              ),
              body: _Body(bill: state.bill),
            );
          }
          if (state is LoadingBillDetail) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
class _Body extends StatelessWidget {
  const _Body({required this.bill});
  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    final status   = BillStatusHelper.getStatus(isPaid: bill.isPaid, dueDate: bill.dueDate);
   // final alarmSet = AlarmService.instance.isAlarmSet(bill.key);

    return Column(
      children: [
        // ── Purple header ───────────────────────────
        Container(
          color: AppColors.primary,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppSizes.sm,
            bottom: AppSizes.xl, left: AppSizes.sm, right: AppSizes.lg,
          ),
          child: Column(children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 20),
              ),
              const Text('Bill detail', style:TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w600,
              ),),
            ]),
            const SizedBox(height: AppSizes.lg),
            _CategoryIcon(category: bill.category),
            const SizedBox(height: AppSizes.sm),
            Text(bill.name, style: const TextStyle(
              color: AppColors.white, fontSize: AppSizes.fontXl, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: AppSizes.xs),
            Text(CurrencyFormatter.format(bill.amount), style: const TextStyle(
              color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: AppSizes.sm),
            StatusBadge(status: status),
          ]),
        ),

        // ── Detail rows ─────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(children: [
              _Card(children: [
                _Row(label: 'Due date',  value: DateFormatter.toDisplay(bill.dueDate)),
                _Row(label: 'Category',  value: bill.category),
                _Row(label: 'Reminder',  value: bill.remindBefore),
                _Row(label: 'Repeat',    value: bill.repeat),
                _Row(
                  label: 'Alarm',
                  value:  'Set — ${DateFormatter.toDisplay(bill.dueDate)} 8:00 AM' ,
                  valueColor:   AppColors.textSecondary,
                ),
                _Row(label: 'Added',     value: DateFormatter.toDisplay(bill.createdAt)),
              ]),
              const SizedBox(height: AppSizes.lg),

              // ── Action buttons ─────────────────────
              if (!bill.isPaid)
                BlocBuilder<BillDetailBloc, BillDetailState>(
                  builder: (ctx, state) => AppButton(
                    label: AppStrings.markPaid,
                    isLoading: state is LoadingBillDetail,
                    onPressed: () => ctx.read<BillDetailBloc>()
                        .add(MarkPaidEvent(bill)),
                  ),
                ),
              const SizedBox(height: AppSizes.sm),
              BlocBuilder<BillDetailBloc, BillDetailState>(
                builder: (ctx, state) => AppButton(
                  label: AppStrings.deleteBill,
                  variant: AppButtonVariant.danger,
                  isLoading: state is LoadingBillDetail,
                  onPressed: () => _confirmDelete(ctx),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete bill?'),
        content: Text('This will delete "${bill.name}" and cancel its alarm.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BillDetailBloc>().add(DeleteBillEvent(bill));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.overdueText)),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (category.toLowerCase()) {
      'utilities' => '💡', 'internet' => '🌐', 'mobile' => '📱',
      'water'     => '💧', 'rent'     => '🏠', 'gas'    => '🔥',
      _           => '📄',
    };
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      border: Border.all(color: AppColors.divider, width: 0.5),
    ),
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});
  final String label, value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(
            fontSize: AppSizes.fontSm, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(
          fontSize: AppSizes.fontSm, fontWeight: FontWeight.w500,
          color: valueColor ?? AppColors.textPrimary,
        )),
      ],
    ),
  );
}
