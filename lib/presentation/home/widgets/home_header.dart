import 'package:bill_mate/presentation/home/widgets/stat_card.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/home_state.dart';
class HomeHeader extends StatelessWidget {
  final HomeState state;
  const HomeHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      expandedHeight: 130,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(
                    color: Colors.white60, fontSize: AppSizes.fontSm),
              ),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'BM',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state is HomeLoaded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
                  child: Row(
                    children: [
                      StatCard(
                        label: AppStrings.totalDue,
                        value: (state as HomeLoaded).grouped.totalDue.toString(),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      StatCard(
                        label: AppStrings.dueSoon,
                        value: (state as HomeLoaded).grouped.dueSoonCount.toString(),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      StatCard(
                        label: AppStrings.overdue,
                        value: (state as HomeLoaded).grouped.overdueCount.toString(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
