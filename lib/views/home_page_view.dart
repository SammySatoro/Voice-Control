import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../applications_manager.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

ApplicationsInfo appsInfo = ApplicationsInfo();

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
      body: showApps ? ListView.builder(
        itemCount: appsInfo.length(),
        itemBuilder: (BuildContext context, int index) {
          ApplicationInfo app = appsInfo.info[index];
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(app.added! ? 4 : 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: app.added! ? Colors.green : Colors.brown,
                    width: app.added! ? 3 : 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.memory(
                      app.icon!,
                      width: 50,
                      height: 50,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(app.name!),
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
                          app.added = !app.added!;
                        });
                        print(app.added);
                      },
                      icon: app.added!
                          ? const Icon(Icons.close)
                          : const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            },
          );

        },
      ) : const Text("Nothing here"),
    );
  }
}


void _openApp(String packageName) {

}