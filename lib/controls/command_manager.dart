import 'package:flutter/material.dart';

class Command {
  static final allEng = [changeLang['eng'], openApp['eng']];
  static final allRu = [changeLang['ru'], openApp['ru']];

  static const changeLang = {'eng': 'change language', 'ru': 'смени язык'};
  static const openApp = {'eng': 'open', 'ru': 'открой'};

}

class Utils {
  static void scanText(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.changeLang["eng"] as Pattern)) {
      final body = _getTextAfterCommand(text: text, command: Command.changeLang["eng"]!);
    }
  }

  static String? _getTextAfterCommand({required String text, required String command}) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return null;
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static void changeLanguage(String) {

  }

}