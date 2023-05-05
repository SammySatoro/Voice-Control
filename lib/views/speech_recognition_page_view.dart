import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:voice_control/controls/applications_manager.dart';
import 'package:voice_control/main.dart';
import '../controls/command_manager.dart';
import 'home_page_view.dart';

class SpeechRecognitionPageView extends StatefulWidget {
  const SpeechRecognitionPageView({super.key});

  @override
  SpeechRecognitionPageViewState createState() => SpeechRecognitionPageViewState();
}

class SpeechRecognitionPageViewState extends State<SpeechRecognitionPageView> with AutomaticKeepAliveClientMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _currentWords = '';
  String _selectedLocaleId = 'en-US';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition'),
        actions: [
          Center(
            child: Text(
              _selectedLocaleId == 'en-US' ?  'eng' : 'рус',
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _selectedLocaleId = _selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
                });
              },
              icon: const Icon(Icons.language)
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.brown,
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _currentWords.isNotEmpty
                        ? _currentWords
                        : _speechAvailable
                        ? 'Tap the microphone to start listening...'
                        : 'Speech not available',
                    style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              ),
            ),
            // AppsInfoInheritedWidget(
            //     appsInfo: appsInfo,
            //     child: Container(),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }

  printLocales() async {
    var locales = await _speechToText.locales();
    for (var local in locales) {
      debugPrint(local.name);
      debugPrint(local.localeId);
    }
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
    _startListening();
  }

  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechEnabled) {
      setState(() {
        changeLanguageVoiceCommand(_currentWords);
        openAppVoiceCommand(_currentWords);
        print(_currentWords);
        _speechEnabled = false;
      });
      await _startListening();
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
        onError: errorListener,
        onStatus: statusListener
    );
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future _startListening() async {
    debugPrint("=================================================");
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation
    );
    setState(() {
      _speechEnabled = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future _stopListening() async {
    setState(() {
      _speechEnabled = false;
    });
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
    });
  }

  void changeLanguageVoiceCommand(String rawText) {
    final text = rawText.toLowerCase();

    if (_selectedLocaleId == 'en-US') {
      if (text.contains(Command.changeLang['eng']!) && text.indexOf(Command.changeLang['eng']!) == 0) {
        _selectedLocaleId = _selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
      }
    } else {
      if (text.contains(Command.changeLang['ru']!) && text.indexOf(Command.changeLang['ru']!) == 0) {
        _selectedLocaleId = _selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
      }
    }
  }
  
  void openAppVoiceCommand(String rawText) {
    final text = rawText.toLowerCase();
    final List splitText = text.split(' ');
    final appName = splitText.sublist(1).join(" ").toLowerCase();
    final int appIndex = appsInfo.value!.appNames.indexOf(appName);
    print("$appName $appIndex $splitText ${splitText[0].indexOf(Command.openApp['eng']!)}");
    if (_selectedLocaleId == 'en-US') {
      if (splitText[0].indexOf(Command.openApp['eng']!) == 0 && appIndex != -1) {
        print("I'M HERE");
        LaunchApp.openApp(
          androidPackageName: ApplicationsInfo.instance.packageNames[appIndex],
        );
        _currentWords = "";
      }
    } else {
      if (splitText[0].indexOf(Command.openApp['ru']!) == 0 && appIndex != -1) {
        LaunchApp.openApp(
          androidPackageName: ApplicationsInfo.instance.packageNames[appIndex],
        );
        _currentWords = "";
      }
    }
  }
}