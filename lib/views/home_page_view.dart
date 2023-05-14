import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:voice_control/views/application_tile_view.dart';
import '../controls/applications_manager.dart';
import 'package:external_app_launcher/external_app_launcher.dart';



class HomePageView extends StatefulWidget {

  const HomePageView ({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  bool showApps = false;

  showAppList(bool showed) {
    setState(() {
      showApps = showed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Voice Control',
          )
      ),
      body: ListView.builder(
        itemCount: ApplicationsInfo.instance.applicationsFromDB!.length,
        itemBuilder: (BuildContext context, int index) {
          final app = ApplicationsInfo.instance.applicationsFromDB![index];
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ApplicationTileView(app: app);
            },
          );

        },
      )
    );
  }
}
