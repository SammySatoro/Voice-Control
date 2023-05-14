import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:device_apps/device_apps.dart';

import '../database/voice_commands_database.dart';

class ApplicationInfo {

  late ApplicationWithIcon instance;

  late String? name;
  late String? packageName;
  late Uint8List icon;
  late int? versionCode;
  late int? versionName;

  ApplicationInfo({
    required this.name,
    required this.packageName,
    required this.icon,
    required this.versionCode,
    required this.versionName,
  });

}

class ApplicationsInfo {

  ApplicationsInfo._();

  static final ApplicationsInfo instance = ApplicationsInfo._();

  List? _installedApps;
  final List<ApplicationWithIcon> _applicationsFromDB = [];
  final List<String> appNames = [];
  final List<String> packageNames = [];
  List<String>? _applicationPackageNamesFromDB = [];

  List? get installedApps => _installedApps;

  List? get applicationsFromDB => _applicationsFromDB;

  bool get isInstalledAppsInitialized => _installedApps != null;

  Future<void> fetchInstalledApps() async {
    _installedApps ??= await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    await getApplicationPackageNamesFromDB();
    _installedApps!.sort((a, b) => a.appName.compareTo(b.appName));
    _getData();
  }


  Future<void> getApplicationPackageNamesFromDB() async {
    _applicationPackageNamesFromDB = await VoiceCommandsDataBase.instance.getUniqueApplicationPackageNames();
  }

  void _getData() {
    for (ApplicationWithIcon element in _installedApps!) {
      appNames.add(element.appName.toLowerCase());
      packageNames.add(element.packageName);
      if (_applicationPackageNamesFromDB!.contains(element.packageName)) {
        _applicationsFromDB.add(element);
      }
    }
  }
}
