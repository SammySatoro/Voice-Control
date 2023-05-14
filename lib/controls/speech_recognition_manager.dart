import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';


class SpeechRecognitionManager {
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;
  bool speechAvailable = false;
  String currentWords = '';
  String selectedLocaleId = 'en-US';
  Map<dynamic, dynamic> currentWidgetPosition = {
    "packageName": "",
    "x": 0,
    "y": 0,
  };
  List<List<int>> testCoords = [];


  SpeechToText get speechToText => _speechToText;

  SpeechRecognitionManager._internal();

  static SpeechRecognitionManager? _instance;

  factory SpeechRecognitionManager() {
    _instance ??= SpeechRecognitionManager._internal();
    return _instance!;
  }


  Future<void> initSpeech({
    required void Function(SpeechRecognitionError) onError,
    required void Function(String) onStatus,
  }) async {
    speechAvailable = await _speechToText.initialize(
      onError: onError,
      onStatus: onStatus,
    );
  }

  Future<void> startListening({
    required void Function(SpeechRecognitionResult) onResult,
  }) async {
    await stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
      onResult: onResult,
      localeId: selectedLocaleId,
      cancelOnError: false,
      partialResults: true,
      listenMode: ListenMode.dictation,
    );
    speechEnabled = true;
  }

  Future<void> stopListening() async {
    speechEnabled = false;
    await _speechToText.stop();
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
    startListening;
  }

  Future<void> printLocales() async {
    var locales = await _speechToText.locales();
    for (var local in locales) {
      debugPrint(local.name);
      debugPrint(local.localeId);
    }
  }

}
