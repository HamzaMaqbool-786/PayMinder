import 'package:bill_mate/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_hive_keys.dart';
import 'core/theme/app_theme.dart';
import 'data/models/bill_model.dart';
import 'presentation/bill_detail/bill_detail_screen.dart';
import 'presentation/main_navigation.dart';
import 'presentation/splash/splash_screen.dart'; // ← add import
import 'services/alarm_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BillModelAdapter());
  await Hive.openBox<BillModel>(HiveKeys.billBox);
  await Hive.openBox(HiveKeys.settingsBox);

  await NotificationService.instance.init();
  await AlarmService.instance.init();

  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/splash', // ← change from '/' to '/splash'
      routes: {
        '/splash':      (_) => const SplashScreen(),     // ← add
        '/':            (_) => const MainNavigation(),
        '/bill-detail': (_) => const BillDetailScreen(),
      },
    );
  }
}