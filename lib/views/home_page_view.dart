import 'package:flutter/material.dart';
import 'package:voice_control/database/voice_commands_database.dart';
import 'package:voice_control/views/application_tile_view.dart';
import '../controls/applications_manager.dart';
import '../controls/native/channel_manager.dart';
import '../controls/notifications/notification_manager.dart';
import '../controls/speech_recognition_manager.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  bool showApps = false;
  final notificationManager = NotificationManager();
  
  showAppList(bool showed) {
    setState(() {
      showApps = showed;
    });
  }

  Future<void> onOpeningAccessibilitySettings() async {
    await ChannelManager.instance.openAccessibilitySettings();
  }

  Future<List<Map<String, dynamic>>> getVoiceCommands(String packageName) async {
    return await VoiceCommandsDataBase.instance.getRecordsPackageName(packageName);
  }

  void deleteApplicationVoiceCommands(String packageName) async {
    await VoiceCommandsDataBase.instance.deleteApplicationCommands(packageName);
  }

  @override
  void initState() {
    super.initState();
    VoiceCommandsDataBase.redrawHomePageView = () {
      setState(() {});
    };
    ChannelManager.platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onViewClicked':
          SpeechRecognitionManager().currentWidgetInfo = call.arguments;
          break;
        default:
          print('Unknown method ${call.method}');
      }
    });
  }

  @override
  void dispose() {
    VoiceCommandsDataBase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Control'),
        actions: [

          IconButton(
              onPressed: onOpeningAccessibilitySettings,
              icon: const Icon(Icons.settings_accessibility)
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: ApplicationsInfo.instance.applicationsFromDB!.length,
        itemBuilder: (BuildContext context, int index) {
          final app = ApplicationsInfo.instance.applicationsFromDB![index];

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: getVoiceCommands(app.packageName),
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ApplicationTileView(
                    app: app,
                    voiceCommands: snapshot.data!,
                    onDelete: () {
                      setState(() {
                        deleteApplicationVoiceCommands(app.packageName);
                      });
                    },
                  );
                } else {
                  return const Center(child: Text('Error fetching voice commands'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
