import 'package:flutter/services.dart';

class ChannelManager {
  ChannelManager._();

  static final ChannelManager instance = ChannelManager._();

  static const platform = MethodChannel("widgets-channel");

  Future<List<dynamic>?> getWidgetsFromApp(String packageName) async {
    try {
      final List<dynamic> widgets =
        await platform.invokeMethod('getWidgets', {'packageName': packageName});
      return widgets;
    } on PlatformException catch (e) {
      print("Error getting widgets from app: ${e.message}");
      return [];
    }
  }

  Future<Map<dynamic, dynamic>> getClickedViewInfo(Map<dynamic, dynamic> arguments) async {
    try {
      print("getClickedViewInfo: $arguments");
      return arguments;
    } on PlatformException catch (e) {
      print("Error getting clicked view info: ${e.message}");
      return {};
    }
  }
  
  Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
      print("openAccessibilitySettings");
    } on PlatformException catch (e) {
      print("Error opening accessibility settings: ${e.message}");
    }
  }

  Future<void> clickAt(int x, int y) async {
    await platform.invokeMethod('clickAt', {'x': x, 'y': y});
  }

}