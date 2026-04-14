import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.only(
      left: AppSizes.lg, right: AppSizes.lg, top: AppSizes.lg, bottom: AppSizes.xs,
    ),
    child: Text(title, style: const TextStyle(
      fontSize: AppSizes.fontXs, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary, letterSpacing: 0.6,
    )),
  );
}
