import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'demo/demo_seed.dart';
import 'core/constants/route_names.dart';
import 'routes/app_router.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Hive storage
  await StorageService.initialize();

  // Initialize notifications
  await NotificationService.initialize();

  const demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
  if (demoMode) {
    await seedDemoData();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      onGenerateRoute: AppRouter().onGenerateRoute,
      initialRoute: RouteNames.home,
    );
  }
}


