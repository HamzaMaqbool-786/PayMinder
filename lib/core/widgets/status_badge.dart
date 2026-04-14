import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../utils/bill_status_helper.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final BillStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
    decoration: BoxDecoration(
      color: BillStatusHelper.getBg(status),
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
    child: Text(
      BillStatusHelper.getLabel(status),
      style: TextStyle(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w500,
        color: BillStatusHelper.getFg(status),
      ),
    ),
  );
}
