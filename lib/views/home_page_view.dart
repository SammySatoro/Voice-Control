import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
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
        itemCount: ApplicationsInfo.instance.installedApps!.length,
        itemBuilder: (BuildContext context, int index) {
          final app = ApplicationsInfo.instance.installedApps![index];
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(true ? 4 : 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: true ? Colors.green : Colors.brown,
                    width: true ? 3 : 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.memory(
                      app! is ApplicationWithIcon ? app.icon : null,
                      width: 50,
                      height: 50,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(app.appName),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        LaunchApp.openApp(
                          androidPackageName: app.packageName,
                        );
                      },
                      icon: const Icon(Icons.start),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          // app.added = !app.added!;
                        });
                        // print(app.added);
                      },
                      icon: true
                          ? const Icon(Icons.close)
                          : const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            },
          );

        },
      )
    );
  }
}
