import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';


class ApplicationInfo {

  late Uint8List? icon;
  late String? name;
  late String? packageName;
  late int? versionCode;
  late int? versionName;
  late bool? added;

  ApplicationInfo({
    required this.icon,
    required this.name,
    required this.packageName,
    required this.versionCode,
    required this.versionName,
    required this.added,
  });

}

class ApplicationsInfo {

  Future<List<AppInfo>>? _installedAppsFuture;
  List<ApplicationInfo>? _appsInfo;

  ApplicationsInfo() {
    _installedAppsFuture = InstalledApps.getInstalledApps(true, true);
    _getApplicationsData();
  }


  void _getApplicationsData() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(
        true, true);
    _appsInfo = installedApps.map((app) {
      return ApplicationInfo(
        icon: app.icon,
        name: app.name,
        packageName: app.packageName,
        versionCode: app.versionCode,
        versionName: app.versionCode,
        added: false,
      );
    }).toList();
  }

  get info {
    return _appsInfo;
  }

  int length() {
    return _appsInfo!.length;
  }
}
