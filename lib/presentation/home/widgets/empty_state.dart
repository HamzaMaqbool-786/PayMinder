import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Center(child: Text('🧾', style: TextStyle(fontSize: 32))),
      ),
      const SizedBox(height: AppSizes.lg),
      const Text(AppStrings.noBills, textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
    ]),
  );
}
