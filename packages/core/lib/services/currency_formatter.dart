import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(num value) {
    final nf = NumberFormat.currency(
      locale: 'sw_TZ',
      symbol: 'MRU',
      decimalDigits: 1,
    );
    return nf.format(value);
  }
}
