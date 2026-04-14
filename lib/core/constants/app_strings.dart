class AppStrings {
  AppStrings._();
  static const String appName     = 'PayMinder';
  static const String appTagline  = 'Never miss a payment';
  static const String navHome     = 'Home';
  static const String navAdd      = 'Add';
  static const String navHistory  = 'History';
  static const String navSettings = 'Settings';
  static const String totalDue    = 'Total due';
  static const String dueSoon     = 'Due soon';
  static const String overdue     = 'Overdue';
  static const String paid        = 'Paid';
  static const String upcoming    = 'Upcoming';
  static const String noBills     = 'No bills yet.\nTap + to add one.';
  static const String addBill     = 'Add new bill';
  static const String editBill    = 'Edit bill';
  static const String billName    = 'Bill name';
  static const String amount      = 'Amount (Rs)';
  static const String dueDate     = 'Due date';
  static const String category    = 'Category';
  static const String remindMe    = 'Remind me';
  static const String repeat      = 'Repeat';
  static const String saveAlarm   = 'Save bill + set alarm';
  static const String markPaid    = 'Mark as paid';
  static const String deleteBill  = 'Delete bill';
  static const String paymentHistory   = 'Payment history';
  static const String totalPaidMonth   = 'Total paid this month';
  static const String settings         = 'Settings';
  static const String notifications    = 'NOTIFICATIONS';
  static const String billReminders    = 'Bill reminders';
  static const String alarmSoundLabel  = 'Alarm sound';
  static const String vibrationLabel   = 'Vibration';
  static const String defaultRemind    = 'Default remind time';
  static const String appearanceLabel  = 'APPEARANCE';
  static const String darkModeLabel    = 'Dark mode';
  static const String currencyLabel    = 'Currency';
  static const String dataLabel        = 'DATA';
  static const String clearAllData     = 'Clear all data';

  static const List<String> categories = [
    'Utilities','Internet','Mobile','Rent','Gas','Water','Other',
  ];
  static const List<String> remindOptions = [
    '1 day before','3 days before','1 week before','On due date',
  ];
  static const List<String> repeatOptions = [
    'None','Monthly','Yearly',
  ];
}
