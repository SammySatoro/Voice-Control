import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_control/controls/background_services_manager.dart';

import 'controls/applications_manager.dart';
import 'views/root_page_view.dart';


ValueNotifier<ApplicationsInfo?> appsInfo = ValueNotifier<ApplicationsInfo?>(null);

Future<void> _fetchAppsAndNotify() async {
  await ApplicationsInfo.instance.fetchInstalledApps();
  appsInfo.value = ApplicationsInfo.instance;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await initializeService();
  _fetchAppsAndNotify();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.orange
      ),
      home: const RootPageView(
      ),
    );
  }
}

