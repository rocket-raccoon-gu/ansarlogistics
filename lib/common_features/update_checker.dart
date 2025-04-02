import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class UpdateChecker {
  static Future<bool> isUpdateRequired() async {
    try {
      // Initialize Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults({
        'min_required_version': '1.0.0', // Default value
      });
      await remoteConfig.fetchAndActivate();

      // Get versions
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final minVersion = remoteConfig.getString('min_required_version');

      log(currentVersion);

      return _compareVersions(currentVersion, minVersion) < 0;
    } catch (e) {
      debugPrint('Update check error: $e');
      return false; // Allow app to run if check fails
    }
  }

  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < v1Parts.length; i++) {
      if (v2Parts.length <= i) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    return 0;
  }
}
