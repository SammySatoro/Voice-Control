import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import 'package:device_apps/device_apps.dart';

class ApplicationInfo {

  late Application instance;

  late String? name;
  late String? packageName;
  late int? versionCode;
  late int? versionName;
  late bool? added;

  ApplicationInfo({
    required this.name,
    required this.packageName,
    required this.versionCode,
    required this.versionName,
    required this.added,
  });

}

class ApplicationsInfo {
  // Make the constructor private to prevent instantiating the class from other files
  ApplicationsInfo._();

  // Create a static instance of the class
  static final ApplicationsInfo instance = ApplicationsInfo._();

  List? _installedApps;
  List<String> appNames = [];
  List<String> packageNames = [];

  List? get installedApps => _installedApps;

  bool get isInstalledAppsInitialized => _installedApps != null;

  Future<void> fetchInstalledApps() async {
    _installedApps ??= await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    _installedApps!.sort((a, b) => a.appName.compareTo(b.appName));
    for (Application element in _installedApps!) {
      appNames.add(element.appName.toLowerCase());
      packageNames.add(element.packageName);
    }
  }
}
