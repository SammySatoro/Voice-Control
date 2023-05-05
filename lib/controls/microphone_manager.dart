import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechApi {
  static final speech = SpeechToText();

  static Future<bool> toggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (speech.isListening) {
      speech.stop();
      return true;
    }
    final isAvailable = await speech.initialize(
      onStatus: (status) => onListening(speech.isListening),
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      if (!speech.isListening) {
        speech.listen(onResult: (value) {
          onResult(value.recognizedWords);
        },
        );
      } else {
        speech.stop();
      }
    }

    return isAvailable;
  }

}

