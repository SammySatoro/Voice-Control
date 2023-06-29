import 'package:device_apps/device_apps.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:voice_control/database/voice_command_model.dart';
import 'package:voice_control/views/voice_command_view.dart';

import '../database/voice_commands_database.dart';

class ApplicationTileView extends StatefulWidget {
  final ApplicationWithIcon app;
  final VoidCallback onDelete;
  List<Map<String, dynamic>> voiceCommands;
  ApplicationTileView({super.key, required this.app, required this.voiceCommands, required this.onDelete});

  @override
  State<ApplicationTileView> createState() => _ApplicationTileViewState();
}

class _ApplicationTileViewState extends State<ApplicationTileView> {
  bool _isListDropped = false;

  void deleteVoiceCommand(String voiceCommandId) async {
    await VoiceCommandsDataBase.instance.delete(int.parse(voiceCommandId));
    final updatedVoiceCommands = await VoiceCommandsDataBase.instance.getRecordsPackageName(widget.app.packageName);
    setState(() {
      widget.voiceCommands = updatedVoiceCommands;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.voiceCommands.isEmpty) {
      return Container(); // Return an empty container to effectively remove the widget from view
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isListDropped = !_isListDropped;
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
                    onPressed: () {
                      setState(() {
                        widget.onDelete();
                      });
                    },
                    icon: const Icon(Icons.delete_outline)
                ),
              ],
            ),
          ),
          if (_isListDropped && widget.voiceCommands.isNotEmpty)
            ...widget.voiceCommands.map((voiceCommand) =>
                ListTile(
                  title: VoiceCommandView(
                    voiceCommand: VoiceCommand.fromJson(voiceCommand),
                    onDelete: () {
                      setState(() {
                        deleteVoiceCommand(voiceCommand["_id"].toString());
                      });
                    },
                  ),
                )
            ),
        ],
      ),
    );
  }
}
