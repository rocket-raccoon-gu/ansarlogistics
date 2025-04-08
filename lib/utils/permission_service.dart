import 'dart:async';
import 'dart:developer';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // List of all permissions needed by the app
  final List<Permission> _requiredPermissions = [
    Permission.location,
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.activityRecognition,
    Permission.notification,
    Permission.phone,
    Permission.storage,
    Permission.camera,
  ];

  // Permission groups that should be requested together
  final Map<String, List<Permission>> _permissionGroups = {
    'location': [Permission.locationWhenInUse, Permission.locationAlways],
  };

  // Check if all permissions are granted
  Future<bool> checkAllPermissions() async {
    for (final permission in _requiredPermissions) {
      if (!(await permission.isGranted)) {
        return false;
      }
    }
    return true;
  }

  // Request all permissions with proper grouping and delays
  Future<bool> requestAllPermissions(BuildContext context) async {
    try {
      // Request location permissions first as a group
      final locationGranted = await _handlePermissionGroup(
        _permissionGroups['location']!,
        context,
        groupName: 'Location',
      );

      if (!locationGranted) {
        _showToast(
          'Location permissions are required for core functionality',
          context,
        );
      }

      // Request other permissions individually with delays
      for (final permission in _requiredPermissions) {
        // Skip if already granted or part of a group we already handled
        if (await permission.isGranted ||
            _permissionGroups.values.any(
              (group) => group.contains(permission),
            )) {
          continue;
        }

        final granted = await _handleSinglePermission(permission, context);
        if (!granted) {
          log('Permission denied: ${permission.toString().split('.').last}');
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return await checkAllPermissions();
    } catch (e, stackTrace) {
      log('Permission request error: $e', stackTrace: stackTrace);
      if (!context.mounted) return false;

      _showToast(
        'Error requesting permissions. Some features may not work.',
        context,
      );
      return false;
    }
  }

  // Handle a group of related permissions
  Future<bool> _handlePermissionGroup(
    List<Permission> permissions,
    BuildContext context, {
    required String groupName,
  }) async {
    try {
      // Check if any permission in the group is already granted
      bool anyGranted = false;
      for (final permission in permissions) {
        if (await permission.isGranted) {
          anyGranted = true;
          break;
        }
      }

      if (anyGranted) return true;

      // Request the primary permission in the group
      final primaryPermission = permissions.first;
      final status = await primaryPermission.request();

      if (status.isPermanentlyDenied) {
        if (!context.mounted) return false;
        _showPermissionSettingsDialog(context, groupName);
        return false;
      }

      if (status.isGranted) {
        // Request subsequent permissions in the group if first was granted
        for (final permission in permissions.skip(1)) {
          await permission.request();
          await Future.delayed(const Duration(milliseconds: 200));
        }
        return true;
      }

      return false;
    } catch (e) {
      log('Error handling permission group $groupName: $e');
      return false;
    }
  }

  // Handle a single permission request
  Future<bool> _handleSinglePermission(
    Permission permission,
    BuildContext context,
  ) async {
    try {
      final status = await permission.request();

      if (status.isPermanentlyDenied) {
        if (!context.mounted) return false;
        _showPermissionSettingsDialog(
          context,
          permission.toString().split('.').last,
        );
        return false;
      }

      return status.isGranted;
    } catch (e) {
      log('Error handling permission ${permission.toString()}: $e');
      return false;
    }
  }

  // Show dialog to guide user to app settings
  void _showPermissionSettingsDialog(
    BuildContext context,
    String permissionName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(
              '$permissionName permission is required for this feature. '
              'Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  // Helper method to show toast messages
  void _showToast(String message, BuildContext context) {
    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.BOTTOM,
    //   backgroundColor: Colors.black54,
    //   textColor: Colors.white,
    // );
    showSnackBar(
      context: context,
      snackBar: showErrorDialogue(errorMessage: message),
    );
  }
}
