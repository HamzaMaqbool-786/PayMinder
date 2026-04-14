import 'package:flutter/material.dart';
import '../../data/models/bill_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/bill_status_helper.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    required this.onTap,
    this.onLongPress,
  });
  final BillModel bill;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final status = BillStatusHelper.getStatus(isPaid: bill.isPaid, dueDate: bill.dueDate);
    final days   = DateFormatter.daysUntil(bill.dueDate);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            _CategoryIcon(category: bill.category),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.name, style: const TextStyle(
                    fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
                  )),
                  const SizedBox(height: 2),
                  Text(_dateLabel(bill.isPaid, days, bill.dueDate),
                    style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(bill.amount),
                  style: TextStyle(
                    fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500,
                    color: BillStatusHelper.getFg(status),
                  )),
                const SizedBox(height: 4),
                StatusBadge(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(bool isPaid, int days, DateTime dueDate) {
    if (isPaid)  return 'Paid ${DateFormatter.toDisplay(dueDate)}';
    if (days < 0) return 'Was due ${DateFormatter.toDisplay(dueDate)}';
    return 'Due ${DateFormatter.toDisplay(dueDate)}';
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final data = _data(category);
    return Container(
      width: AppSizes.iconXl, height: AppSizes.iconXl,
      decoration: BoxDecoration(color: data.$2, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      child: Center(child: Text(data.$1, style: const TextStyle(fontSize: 18))),
    );
  }

  (String, Color) _data(String cat) => switch (cat.toLowerCase()) {
    'utilities' => ('💡', AppColors.catUtilities),
    'internet'  => ('🌐', AppColors.catInternet),
    'mobile'    => ('📱', AppColors.catMobile),
    'water'     => ('💧', AppColors.catWater),
    'rent'      => ('🏠', AppColors.catRent),
    'gas'       => ('🔥', AppColors.catGas),
    _           => ('📄', AppColors.catOther),
  };
}
