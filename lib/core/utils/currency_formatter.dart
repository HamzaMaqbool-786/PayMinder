import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();
  static final _fmt = NumberFormat('#,##0', 'en_US');
  static String format(double amount, {String symbol = 'Rs'}) =>
      '$symbol ${_fmt.format(amount)}';
  static String formatRaw(double amount) => _fmt.format(amount);
}
