import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:voice_control/controls/background_services_manager.dart';
import 'package:voice_control/controls/microphone_manager.dart';

class PresetsPageView extends StatefulWidget {

  const PresetsPageView ({Key? key}) : super(key: key);

  @override
  State<PresetsPageView> createState() => PresetsPageViewState();
}

class PresetsPageViewState extends State<PresetsPageView> {
  Icon currentGround = const Icon(Icons.double_arrow);
  String text = 'Press the button and start speaking';
  bool isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Presets'
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  onPressed: toggleRecording,
                  child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36,)
              ),
              ElevatedButton(
                  onPressed: () {
                    FlutterBackgroundService().invoke('setAsForeground');
                  },
                  child: const Icon(Icons.door_back_door_outlined)
              ),
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke('setAsBackground');
                },
                child: const Icon(Icons.door_back_door_rounded)
              ),
              ElevatedButton(
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    bool isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke('stopService');
                    } else {
                      service.startService();
                    }
                    toggleRecording();
                    setState(() {
                      if (!isRunning) {
                        currentGround = const Icon(Icons.stop_rounded);
                      } else {
                        currentGround = const Icon(Icons.double_arrow);
                      }
                    });
                  },
                  child: currentGround
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
