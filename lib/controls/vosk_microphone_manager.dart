import 'package:vosk_flutter/vosk_flutter.dart';
import 'dart:io';

class MicrophoneManager {
  final _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  SpeechService? _speechService;
  static const int sampleRate = 16000;

  Future<void> loadModel(String modelPath) async {
    // try {
    //   final enSmallModelPath = await ModelLoader().loadFromAssets(modelPath);
    //   _model = await _vosk.createModel(enSmallModelPath);
    //   print("here========================================");
    // } catch (e) {
    //   print('Error loading model: $e');
    // }
    final enSmallModelPath = await ModelLoader().loadFromAssets(modelPath);
    _model = await _vosk.createModel(enSmallModelPath);
  }

  Future<Recognizer?> createRecognizer() async {
    try {
      if (_model != null) {
        final recognizer = await _vosk.createRecognizer(
          model: _model!,
          sampleRate: sampleRate,
        );
        return recognizer;
      } else {
        throw Exception('Model not loaded');
      }
    } catch (e) {
      print('Error creating recognizer: $e');
      return null;
    }
  }

  Future<void> initSTTService(Recognizer recognizer) async {
    try {
      _speechService = await _vosk.initSpeechService(recognizer);
      _speechService!.onPartial().forEach((partial) => print(partial));
      _speechService!.onResult().forEach((result) => print(result));
    } catch (e) {
      print('Error initializing STT service: $e');
    }
  }

  Future<void> startService(Recognizer recognizer) async {
    try {
      await _speechService!.start();
    } catch (e) {
      print('Error starting service: $e');
    }
  }
}
