import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/bill_model.dart';
import 'bloc/history_bloc.dart';
import 'bloc/history_event.dart';
import 'bloc/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => const _HistoryView();
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (ctx, state) {
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _Header()),
            if (state is HistoryLoaded) ...[
              SliverToBoxAdapter(child: _TotalCard(total: state.totalPaid)),
              SliverToBoxAdapter(
                child: _MonthFilter(
                  months: state.availableMonths,
                  selected: state.selectedMonth,
                  onSelected: (m) =>
                      ctx.read<HistoryBloc>().add(FilterMonthEvent(m)),
                ),
              ),
              if (state.bills.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No paid bills yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _HistoryRow(bill: state.bills[i]),
                    childCount: state.bills.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
            if (state is HistoryLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (state is HistoryError)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.overdueText),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primary,
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + AppSizes.md,
      left: AppSizes.lg,
      right: AppSizes.lg,
      bottom: AppSizes.lg,
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.paymentHistory,
          style: TextStyle(
            color: AppColors.white,
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'All paid bills',
          style: TextStyle(
            color: Colors.white60,
            fontSize: AppSizes.fontSm,
          ),
        ),
      ],
    ),
  );
}

// ── Total Card ─────────────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AppSizes.lg),
    padding: const EdgeInsets.all(AppSizes.lg),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.totalPaidMonth,
              style: TextStyle(
                color: Colors.white60,
                fontSize: AppSizes.fontSm,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Text('📊', style: TextStyle(fontSize: 28)),
      ],
    ),
  );
}

// ── Month Filter ───────────────────────────────────────────────────────────

class _MonthFilter extends StatelessWidget {
  const _MonthFilter({
    required this.months,
    required this.selected,
    required this.onSelected,
  });
  final List<DateTime> months;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.lg,
      vertical: AppSizes.sm,
    ),
    child: Row(
      children: [
        _FilterChip(
          label: 'All',
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        ...months.map(
              (m) => _FilterChip(
            label: DateFormatter.toMonthYear(m).split(' ').first,
            isSelected: selected?.year == m.year &&
                selected?.month == m.month,
            onTap: () => onSelected(m),
          ),
        ),
      ],
    ),
  );
}

// ── Filter Chip ────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    ),
  );
}

// ── History Row ────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.bill});
  final BillModel bill;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.lg,
      vertical: AppSizes.md,
    ),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(
        bottom: BorderSide(color: AppColors.divider, width: 0.5),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.paidBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.paidText,
            size: 16,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bill.name,
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Paid ${DateFormatter.toDisplay(bill.dueDate)}',
                style: const TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          CurrencyFormatter.format(bill.amount),
          style: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
            color: AppColors.paidText,
          ),
        ),
      ],
    ),
  );
}