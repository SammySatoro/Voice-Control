import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:voice_control/controls/background_services_manager.dart';
import 'package:voice_control/controls/microphone_manager.dart';
import 'package:voice_control/controls/native/channel_manager.dart';
import 'package:voice_control/controls/speech_recognition_manager.dart';
import 'package:voice_control/database/voice_command_model.dart';
import 'package:voice_control/database/voice_commands_database.dart';

class PresetsPageView extends StatefulWidget {

  const PresetsPageView ({Key? key}) : super(key: key);

  @override
  State<PresetsPageView> createState() => PresetsPageViewState();
}

class PresetsPageViewState extends State<PresetsPageView> {
  Icon currentGround = const Icon(Icons.double_arrow);
  String text = 'Press the button and start speaking';
  bool isListening = false;
  bool isLoading = false;
  late List<VoiceCommand> voiceCommands;


  Future<void> onButtonPressed() async {
    final List<dynamic>? widgets = await ChannelManager.instance.getWidgetsFromApp("com.coloros.calculator");
    for (var i = 0; i < widgets!.length; i++) {
      debugPrint("#$i  ${widgets[i]}");
    }
    // setState(() {
    //   text = message;
    // });
  }

  Future<void> onGetInfo() async {
    final widgetPosition = SpeechRecognitionManager().currentWidgetPosition;
    final info = "Package Name: ${widgetPosition['packageName']} X: ${widgetPosition['x']} Y: ${widgetPosition['y']}";
    setState(() {
      text = info;
    });
    SpeechRecognitionManager().currentWidgetPosition = widgetPosition;
  }

  Future<void> onOpeningAccessibilitySettings() async {
    await ChannelManager.instance.openAccessibilitySettings();
  }

  @override
  void initState() {
    super.initState();
    ChannelManager.platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onViewClicked':
          SpeechRecognitionManager().currentWidgetPosition = await ChannelManager.instance.getClickedViewInfo(call.arguments);
          SpeechRecognitionManager().testCoords.add([
            SpeechRecognitionManager().currentWidgetPosition["x"],
            SpeechRecognitionManager().currentWidgetPosition["y"]
          ]);
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

  Future refreshVoiceCommands() async {
    setState(() => isLoading = true);

    voiceCommands = await VoiceCommandsDataBase.instance.readAllVoiceCommands();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Presets'
        ),
        actions: [
          IconButton(
              onPressed: onOpeningAccessibilitySettings,
              icon: const Icon(Icons.settings_accessibility)
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    for (VoiceCommand i in (await VoiceCommandsDataBase.instance.readAllVoiceCommands()))
                      print("THIS ONE: ${i.command}");
                  },
                  child: const Icon(Icons.message)
              ),
            ],
          ),
        )
      )
    );
  }

  Future toggleRecording() {
    return SpeechApi.toggleRecording(
      onResult: (text) => setState(() => this.text = text),
      onListening: (isListening) async {
        if (isListening) {
          await initializeService();
        }
        setState(() => this.isListening = isListening);
      },
    );
  }
}






// ElevatedButton(
//     onPressed: () {
//       FlutterBackgroundService().invoke('setAsForeground');
//     },
//     child: const Icon(Icons.door_back_door_outlined)
// ),
// ElevatedButton(
//     onPressed: () {
//       FlutterBackgroundService().invoke('setAsBackground');
//     },
//     child: const Icon(Icons.door_back_door_rounded)
// ),
// ElevatedButton(
//   onPressed: onGetInfo,
//   child: const Icon(Icons.get_app),
// ),
// ElevatedButton(
//     onPressed: () async {
//       final service = FlutterBackgroundService();
//       bool isRunning = await service.isRunning();
//       if (isRunning) {
//         service.invoke('stopService');
//       } else {
//         service.startService();
//       }
//       toggleRecording();
//       setState(() {
//         if (!isRunning) {
//           currentGround = const Icon(Icons.stop_rounded);
//         } else {
//           currentGround = const Icon(Icons.double_arrow);
//         }
//       });
//     },
//     child: currentGround
// ),