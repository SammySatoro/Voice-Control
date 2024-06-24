import 'dart:async';
import 'dart:ffi';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:voice_control/controls/speech_recognition_manager.dart';
import 'package:voice_control/database/voice_command_model.dart';
import 'package:voice_control/database/voice_commands_database.dart';
import '../main.dart';
import 'applications_manager.dart';
import 'native/channel_manager.dart';
import 'notifications/notification_manager.dart';

class Command {
  static final allEng = [changeLang['en-US'], openApp['en-US'], click['en-US'], voiceControl['en-US']];
  static final allRu = [changeLang['ru-RU'], openApp['ru-RU'], click['ru-RU'], voiceControl['ru-RU']];

  static const changeLang = {'en-US': 'change language', 'ru-RU': 'смени язык'};
  static const openApp = {'en-US': 'open', 'ru-RU': 'открой'};
  static const click = {'en-US': 'click', 'ru-RU': 'нажать'};
  static const voiceControl = {'en-US': 'voice control', 'ru-RU': 'запись новой команды'};
}

class CommandUtils {

  static final CommandUtils _instance = CommandUtils._internal();

  factory CommandUtils() {
    return _instance;
  }
  CommandUtils._internal();

  static String currentlyOpenedApplication = "com.example.voice_control";
  final notificationManager = NotificationManager();

  Future<void> _showNotification(title, content) async {
    await notificationManager.showNotification(title, content);
  }

  void changeLanguage(String rawText) {
    final text = rawText.toLowerCase();
    final String locale = SpeechRecognitionManager().selectedLocaleId;
    Map<String, String> language = {"ru-RU": "English", "en-US": "Русский"};
    if (text.contains(Command.changeLang[locale]!) && text.indexOf(Command.changeLang[locale]!) == 0) {
      SpeechRecognitionManager().selectedLocaleId = SpeechRecognitionManager().selectedLocaleId == 'en-US' ?  'ru-RU' : 'en-US';
      _showNotification("Locale", language[locale]);
    }
  }

  void openApp(String rawText) {
    final text = rawText.toLowerCase();
    final List splitText = text.split(' ');
    final appName = splitText.sublist(1).join(" ").toLowerCase();
    final int appIndex = appsInfo.value!.appNames.indexOf(appName);
    final String locale = SpeechRecognitionManager().selectedLocaleId;

    if (splitText[0].indexOf(Command.openApp[locale]!) == 0 && appIndex != -1) {
      LaunchApp.openApp(
        androidPackageName: ApplicationsInfo.instance.packageNames[appIndex],
      );
      SpeechRecognitionManager().currentWords = "";
    }
  }

  void clickByCommand(String rawText) async {
    try {
      currentlyOpenedApplication = (await ChannelManager.instance.getCurrentlyOpenedApplication())!;
      final String locale = SpeechRecognitionManager().selectedLocaleId;
      List<String> tokens = rawText.toLowerCase().split(' ');
      print("currentlyOpenedApplication: $currentlyOpenedApplication");
      final String clickWord = tokens[0];
      if (clickWord != Command.click[locale]) return;
      late String command = tokens.sublist(1).join(" ");
      if (tokens.length == 2) {
        command = _checkIfDigit(tokens[1]);
      }
      final coords = await VoiceCommandsDataBase.instance.getCoordinates(currentlyOpenedApplication, command);
      final Offset offset = Offset(
          coords!["xCoord"]!.toDouble(),
          coords["yCoord"]!.toDouble()
      );
      if (clickWord.indexOf(Command.click[locale]!) == 0) {
        _simulateTap(offset);
        SpeechRecognitionManager().currentWords = "";
      }
    } catch(e) {print(e);}
  }

  String _checkIfDigit(String word) {
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

  void _simulateTap(Offset position) async {
    ChannelManager.instance.clickAt(position.dx.toInt(), position.dy.toInt());
  }

  void recordNewCommand(String rawText) {
    final text = rawText.toLowerCase();
    try {
      final String locale = SpeechRecognitionManager().selectedLocaleId;
      String command = "";
      command = text.split(Command.voiceControl[locale]!)[1].trim();
      command = _checkIfDigit(command);
      print("COMMAND: $command");
      if (text.indexOf(Command.voiceControl[locale]!) == 0) {
        if (command.isNotEmpty) _recordNewCommand(command);
        _showNotification("A new command has been recorded:", "$command");
        SpeechRecognitionManager().currentWords = "";
        VoiceCommandsDataBase.redrawHomePageView();
      }
    } catch(e) {}
  }

  Future<void> _recordNewCommand(String command) async {
    await VoiceCommandsDataBase.instance.create(
        VoiceCommand(
            command: command,
            xCoord: SpeechRecognitionManager().currentWidgetInfo["x"],
            yCoord: SpeechRecognitionManager().currentWidgetInfo["y"],
            applicationPackageName: SpeechRecognitionManager().currentWidgetInfo["packageName"],
            language: SpeechRecognitionManager().selectedLocaleId
        )
    );

  }

}
