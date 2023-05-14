import 'package:device_apps/device_apps.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:voice_control/views/voice_command_view.dart';

class ApplicationTileView extends StatefulWidget {
  final ApplicationWithIcon app;
  const ApplicationTileView({super.key, required this.app});

  @override
  State<ApplicationTileView> createState() => _ApplicationTileViewState();
}

class _ApplicationTileViewState extends State<ApplicationTileView> {
  bool _isListDropped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _isListDropped = !_isListDropped;
        setState(() {

        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.brown,
                width: 3,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.memory(
                  widget.app.icon,
                  width: 50,
                  height: 50,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(widget.app.appName),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    LaunchApp.openApp(
                      androidPackageName: widget.app.packageName,
                    );
                  },
                  icon: const Icon(Icons.open_in_new_outlined),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_outline)
                ),
              ],
            ),
          ),
          if (_isListDropped)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Replace with actual number of nested list items
              itemBuilder: (BuildContext context, int index) {
                return const ListTile(
                  title:  VoiceCommandView(
                    command: "Hello there!",
                    xCoord: "1000",
                    yCoord: "2000",
                  ),
                );
              },
            ),
        ],

      ),
    );
  }
}
