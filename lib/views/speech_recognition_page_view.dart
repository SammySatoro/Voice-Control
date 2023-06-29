import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../controls/command_manager.dart';
import '../controls/notifications/notification_manager.dart';
import '../controls/speech_recognition_manager.dart';


class SpeechRecognitionPageView extends StatefulWidget {
  const SpeechRecognitionPageView({super.key});

  @override
  SpeechRecognitionPageViewState createState() => SpeechRecognitionPageViewState();
}

class SpeechRecognitionPageViewState extends State<SpeechRecognitionPageView> with AutomaticKeepAliveClientMixin {
  final SpeechRecognitionManager _speechRecognitionManager = SpeechRecognitionManager();


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _speechRecognitionManager.initSpeech(
      onError: SpeechRecognitionManager().errorListener,
      onStatus: statusListener,
    );
    _speechRecognitionManager.onResult = _onSpeechResult;
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
              _speechRecognitionManager.selectedLocaleId == 'en-US' ?  'eng' : 'рус',
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _speechRecognitionManager.selectedLocaleId = _speechRecognitionManager.selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
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
                    _speechRecognitionManager.currentWords.isNotEmpty
                        ? _speechRecognitionManager.currentWords
                        : _speechRecognitionManager.speechAvailable
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
        _speechRecognitionManager.speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechRecognitionManager.speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }

  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechRecognitionManager.speechEnabled) {
      setState(() {
        if (_speechRecognitionManager.currentWords.isNotEmpty) {
          CommandUtils().recordNewCommand(_speechRecognitionManager.currentWords);
          CommandUtils().changeLanguage(_speechRecognitionManager.currentWords);
          CommandUtils().openApp(_speechRecognitionManager.currentWords);
          CommandUtils().clickByCommand(_speechRecognitionManager.currentWords);
        }
        print(_speechRecognitionManager.currentWords);
        _speechRecognitionManager.currentWords = '';
        _speechRecognitionManager.speechEnabled = false;
      });
      await _startListening();
    }
  }

  Future _startListening() async {
    await _speechRecognitionManager.startListening();
    setState(() => _speechRecognitionManager.speechEnabled = true);
  }

  Future _stopListening() async {
    setState(() => _speechRecognitionManager.speechEnabled = false);
    await _speechRecognitionManager.stopListening();
    NotificationManager().showNotification("Status:", "Listening has stopped");
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _speechRecognitionManager.currentWords = result.recognizedWords;
    });
  }
}