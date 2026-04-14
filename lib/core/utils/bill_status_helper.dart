import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'date_formatter.dart';

enum BillStatus { overdue, dueToday, dueSoon, upcoming, paid }

class BillStatusHelper {
  BillStatusHelper._();

  static BillStatus getStatus({required bool isPaid, required DateTime dueDate}) {
    if (isPaid) return BillStatus.paid;
    final days = DateFormatter.daysUntil(dueDate);
    if (days < 0)  return BillStatus.overdue;
    if (days == 0) return BillStatus.dueToday;
    if (days <= 3) return BillStatus.dueSoon;
    return BillStatus.upcoming;
  }

  static String getLabel(BillStatus s) => switch (s) {
    BillStatus.overdue  => 'Overdue',
    BillStatus.dueToday => 'Due today',
    BillStatus.dueSoon  => 'Due soon',
    BillStatus.upcoming => 'Upcoming',
    BillStatus.paid     => 'Paid',
  };

  static Color getBg(BillStatus s) => switch (s) {
    BillStatus.overdue  => AppColors.overdueBg,
    BillStatus.dueToday => AppColors.overdueBg,
    BillStatus.dueSoon  => AppColors.dueSoonBg,
    BillStatus.upcoming => AppColors.upcomingBg,
    BillStatus.paid     => AppColors.paidBg,
  };

  static Color getFg(BillStatus s) => switch (s) {
    BillStatus.overdue  => AppColors.overdueText,
    BillStatus.dueToday => AppColors.overdueText,
    BillStatus.dueSoon  => AppColors.dueSoonText,
    BillStatus.upcoming => AppColors.upcomingText,
    BillStatus.paid     => AppColors.paidText,
  };
}
