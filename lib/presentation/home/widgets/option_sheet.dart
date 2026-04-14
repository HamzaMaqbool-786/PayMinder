
import 'package:bill_mate/presentation/home/widgets/tile.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/bill_model.dart';

class OptionsSheet extends StatelessWidget {
  const OptionsSheet({super.key, required this.bill, required this.onMarkPaid, required this.onDelete});
  final BillModel bill;
  final VoidCallback onMarkPaid, onDelete;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull))),
        const SizedBox(height: AppSizes.lg),
        Text(bill.name, style: const TextStyle(
            fontSize: AppSizes.fontLg, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: AppSizes.md),
        if (!bill.isPaid)
          Tile(icon: Icons.check_circle_outline, label: AppStrings.markPaid,
              color: AppColors.paidText, onTap: onMarkPaid),
        Tile(icon: Icons.delete_outline, label: AppStrings.deleteBill,
            color: AppColors.overdueText, onTap: onDelete),
        Tile(icon: Icons.close, label: 'Cancel',
            color: AppColors.textSecondary, onTap: () => Navigator.pop(context)),
      ]),
    ),
  );
}
