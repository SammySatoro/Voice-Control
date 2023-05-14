import 'dart:async';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:voice_control/controls/speech_recognition_manager.dart';
import 'package:voice_control/database/voice_command_model.dart';
import 'package:voice_control/database/voice_commands_database.dart';
import 'package:voice_control/views/presets_page_view.dart';
import '../main.dart';
import 'applications_manager.dart';
import 'native/channel_manager.dart';

class Command {
  static final allEng = [changeLang['eng'], openApp['eng'], click['eng'], voiceControl['eng']];
  static final allRu = [changeLang['ru'], openApp['ru'], click['ru'], voiceControl['ru']];

  static const changeLang = {'eng': 'change language', 'ru': 'смени язык'};
  static const openApp = {'eng': 'open', 'ru': 'открой'};
  static const click = {'eng': 'click', 'ru': 'нажать'};
  static const voiceControl = {'eng': 'voice control', 'ru': 'запись новой команды'};

}

class CommandUtils {

  static void changeLanguage(String rawText) {
    final text = rawText.toLowerCase();

    if (SpeechRecognitionManager().selectedLocaleId == 'en-US') {
      if (text.contains(Command.changeLang['eng']!) && text.indexOf(Command.changeLang['eng']!) == 0) {
        SpeechRecognitionManager().selectedLocaleId = SpeechRecognitionManager().selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
      }
    } else {
      if (text.contains(Command.changeLang['ru']!) && text.indexOf(Command.changeLang['ru']!) == 0) {
        SpeechRecognitionManager().selectedLocaleId = SpeechRecognitionManager().selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
      }
    }
  }

  static void openApp(String rawText) {
    final text = rawText.toLowerCase();
    final List splitText = text.split(' ');
    final appName = splitText.sublist(1).join(" ").toLowerCase();
    final int appIndex = appsInfo.value!.appNames.indexOf(appName);

    if (SpeechRecognitionManager().selectedLocaleId == 'en-US') {
      if (splitText[0].indexOf(Command.openApp['eng']!) == 0 && appIndex != -1) {
        LaunchApp.openApp(
          androidPackageName: ApplicationsInfo.instance.packageNames[appIndex],
        );
        SpeechRecognitionManager().currentWords = "";
      }
    } else {
      if (splitText[0].indexOf(Command.openApp['ru']!) == 0 && appIndex != -1) {
        LaunchApp.openApp(
          androidPackageName: ApplicationsInfo.instance.packageNames[appIndex],
        );
        SpeechRecognitionManager().currentWords = "";
      }
    }
  }

  static void clickOnScreen(String rawText) {
    final text = rawText.toLowerCase();
    final List splitText = text.split(' ');
    try {
      final clickWord = splitText[0];
      final int index = int.parse(_checkIfDigit(splitText[1]));
      final Offset offset = Offset(
          SpeechRecognitionManager().testCoords[index][0].toDouble(),
          SpeechRecognitionManager().testCoords[index][1].toDouble()
      );
      if (SpeechRecognitionManager().selectedLocaleId == 'en-US') {
        if (clickWord.indexOf(Command.click['eng']!) == 0) {
          _simulateTap(offset);
          SpeechRecognitionManager().currentWords = "";
        }
      } else {
        if (clickWord.indexOf(Command.click['ru']!) == 0) {
          _simulateTap(offset);
          SpeechRecognitionManager().currentWords = "";
        }
      }
    } catch(e) {
      print("Error occurred while clicking on screen: $e");
    }
  }

  static void clickByCommand(String rawText) async {
    final text = rawText.toLowerCase();
    try {
      final String clickWord = text.split(' ')[0];
      final String command = text.split(Command.click["eng"]!)[1].trim();
      final coords = await VoiceCommandsDataBase.instance.getCoordinates("com.coloros.calculator", command);
      final Offset offset = Offset(
          coords!["xCoord"]!.toDouble(),
          coords["yCoord"]!.toDouble()
      );
      if (SpeechRecognitionManager().selectedLocaleId == 'en-US') {
        if (clickWord.indexOf(Command.click['eng']!) == 0) {
          _simulateTap(offset);
          SpeechRecognitionManager().currentWords = "";
        }
      } else {
        if (clickWord.indexOf(Command.click['ru']!) == 0) {
          _simulateTap(offset);
          SpeechRecognitionManager().currentWords = "";
        }
      }
    } catch(e) {}
  }

  static String _checkIfDigit(String word) {
    if (SpeechRecognitionManager().selectedLocaleId == "en-US") {
      switch(word) {
        case "zero": word = "0"; break;
        case "one": word = "1"; break;
        case "two": word = "2"; break;
        case "to": word = "2"; break;
        case "three": word = "3"; break;
        case "for": word = "4"; break;
        case "four": word = "4"; break;
        case "five": word = "5"; break;
        case "six": word = "6"; break;
        case "seven": word = "7"; break;
        case "eight": word = "8"; break;
        case "nine": word = "9"; break;
      }
    } else {
      switch(word) {
        case "ноль": word = "0"; break;
        case "один": word = "1"; break;
        case "два": word = "2"; break;
        case "три": word = "3"; break;
        case "четыре": word = "4"; break;
        case "пять": word = "5"; break;
        case "шесть": word = "6"; break;
        case "семь": word = "7"; break;
        case "весемь": word = "8"; break;
        case "девять": word = "9"; break;
      }
    }
    return word;
  }

  static void _simulateTap(Offset position) async {
    ChannelManager.instance.clickAt(position.dx.toInt(), position.dy.toInt());
  }

  static void recordNewCommand(String rawText) {
    final text = rawText.toLowerCase();
    try {
      String command = text.split(Command.voiceControl["eng"]!)[1].trim();
      command = _checkIfDigit(command);
      print("COMMAND: $command");
      if (SpeechRecognitionManager().selectedLocaleId == 'en-US') {
        if (text.indexOf(Command.voiceControl["eng"]!) == 0) {
          if (command.isNotEmpty) _recordNewCommand(command);
          SpeechRecognitionManager().currentWords = "";
        }
      } else {
        if (text.indexOf(Command.voiceControl["ru"]!) == 0) {
          if (command.isNotEmpty) _recordNewCommand(command);
          SpeechRecognitionManager().currentWords = "";
        }
      }
    } catch(e) {}
  }

  static Future<void> _recordNewCommand(String command) async {
    await VoiceCommandsDataBase.instance.create(
        VoiceCommand(
            command: command,
            xCoord: SpeechRecognitionManager().currentWidgetPosition["x"],
            yCoord: SpeechRecognitionManager().currentWidgetPosition["y"],
            applicationPackageName: SpeechRecognitionManager().currentWidgetPosition["packageName"],
            language: SpeechRecognitionManager().selectedLocaleId
        )
    );

  }

}