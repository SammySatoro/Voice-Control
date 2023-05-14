import 'package:flutter/material.dart';
import 'package:voice_control/controls/background_services_manager.dart';
import 'package:voice_control/controls/microphone_manager.dart';
import 'package:voice_control/controls/native/channel_manager.dart';
import 'package:voice_control/controls/speech_recognition_manager.dart';
import 'package:voice_control/database/voice_commands_database.dart';

import '../controls/applications_manager.dart';

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

  // Future refreshVoiceCommands() async {
  //   setState(() => isLoading = true);
  //
  //   applicationPackageNames = await VoiceCommandsDataBase.instance.getUniqueApplicationPackageNames();
  //
  //   setState(() => isLoading = false);
  // }

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