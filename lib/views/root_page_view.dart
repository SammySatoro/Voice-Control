import 'package:flutter/material.dart';
import 'package:voice_control/main.dart';
import 'package:voice_control/views/speech_recognition_page_view.dart';
import '../controls/applications_manager.dart';
import '../controls/notifications/notification_manager.dart';
import 'home_page_view.dart';



class RootPageView extends StatefulWidget {
  const RootPageView({super.key});


  @override
  State<RootPageView> createState() => _RootPageViewState();
}

class _RootPageViewState extends State<RootPageView> {
  int currentPage = 0;
  final notificationManager = NotificationManager();

  List<Widget> getPages() {
    return [
      ValueListenableBuilder<ApplicationsInfo?>(
        valueListenable: appsInfo,
        builder: (BuildContext context, ApplicationsInfo? appsInfoValue, Widget? child) {
          if (appsInfoValue != null && appsInfoValue.installedApps != null) {
            return const HomePageView();
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        },
      ),
      const SpeechRecognitionPageView(),
    ];
  }

  Future<void> initNotificationManager() async {
    await notificationManager.initialize();
  }

  @override
  void initState() {
    super.initState();
    initNotificationManager();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = getPages();
    return Scaffold(
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_rounded),
            label: 'Recognition'
          )
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}