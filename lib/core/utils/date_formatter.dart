import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  static final _display   = DateFormat('MMM d, yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _short     = DateFormat('MMM d');

  static String toDisplay(DateTime d)   => _display.format(d);
  static String toMonthYear(DateTime d) => _monthYear.format(d);
  static String toShort(DateTime d)     => _short.format(d);

  static String toRelative(DateTime date) {
    final today  = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(date.year, date.month, date.day);
    final diff   = target.difference(today).inDays;
    if (diff == 0)  return 'Today';
    if (diff == 1)  return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1)   return '$diff days';
    return '${diff.abs()} days ago';
  }

  static int daysUntil(DateTime dueDate) {
    final today  = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }
}
