import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_control/background_services_manager.dart';

import 'views/root_page_view.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await initializeService();
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

