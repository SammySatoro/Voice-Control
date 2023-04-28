import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class PresetsPageView extends StatefulWidget {

  const PresetsPageView ({Key? key}) : super(key: key);

  @override
  State<PresetsPageView> createState() => _PresetsPageViewState();
}

class _PresetsPageViewState extends State<PresetsPageView> {
  Icon currentGround = const Icon(Icons.backpack_outlined);

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
          padding: const EdgeInsets.fromLTRB(0, 400, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {

                  },
                  child: const Icon(Icons.radio_button_checked)
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
}
