import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Check permission for Camera
  Future<bool> checkAndRequestCameraPermission() =>
      _requestPermission(Permission.camera);

  // Check permission for Media (Photos & Videos)

  Future<bool> checkAndRequestPhotoPermission() async {
    if (Platform.isAndroid) {
      if (await DeviceInfoPlugin().androidInfo.then(
            (info) => info.version.sdkInt,
          ) <
          29) {
        // For Android 9 and below, request Storage permission
        return await _requestPermission(Permission.storage);
      } else {
        // For Android 10+ request Photos and Videos separately
        return await _requestMultiplePermissions([
          Permission.photos,
          Permission.videos,
        ]);
      }
    } else {
      return await _requestPermission(Permission.photos);
    }
  }

  Future<bool> checkAndRequestFilePermission() async {
    if (Platform.isAndroid) {
      int sdkVersion = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (sdkVersion >= 33) {
        // Android 13+ (API 33+)
        return await _requestMultiplePermissions([
          Permission.photos,
          Permission.videos,
          //Permission.audio,
        ]);
      } else if (sdkVersion >= 30) {
        // Android 11-12 (API 30-32)
        bool storagePermission = await _requestPermission(
          Permission.manageExternalStorage,
        );
        return storagePermission;
      } else {
        // Android 9 and below (API 29 and below)
        return await _requestPermission(Permission.storage);
      }
    } else {
      return true;
    }
  }

  // Future<bool> checkAndRequestPhotoManagerPermission() async {
  //   final result = await PhotoManager.requestPermissionExtend();
  //
  //   if (result == PermissionState.authorized) {
  //     // Full access granted
  //     return true;
  //   } else if (result == PermissionState.limited) {
  //     return true;
  //   } else {
  //     // Permission denied or restricted
  //     if (result == PermissionState.denied || result == PermissionState.restricted) {
  //       _showPermissionAlert(); // Show your custom alert to open app settings
  //     }
  //     return false;
  //   }
  // }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        // For Android 11+ (API 30+)
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // Android 9 or 10
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else {
      // For iOS, we can assume permission is granted for storage access
      return true;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();

    if (status.isPermanentlyDenied) {
      _showPermissionAlert();
    }

    return status.isGranted;
  }

  // Check permission for Notifications (Android 13+)
  Future<bool> checkAndRequestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrAbove()) {
        return await _requestPermission(Permission.notification);
      }
    }
    return true; // No need to request on iOS or below Android 13
  }

  Future<bool> _requestMultiplePermissions(List<Permission> permissions) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allGranted = statuses.values.every((status) => status.isGranted);
    bool permanentlyDenied = statuses.values.any(
      (status) => status.isPermanentlyDenied,
    );

    if (permanentlyDenied) {
      _showPermissionAlert();
    }

    return allGranted;
  }

  // Show a custom permission alert
  void _showPermissionAlert() {
    // Show your custom alert dialog or snackbar here
    // For example:
    // showDialog(
    //   context: buildC,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Permission Required'),
    //       content: Text('Please grant the required permissions in settings.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             openAppSettings();
    //             Navigator.of(context).pop();
    //           },
    //           child: Text('Open Settings'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  // Check if the Android version is 13 (API 33) or above
  Future<bool> _isAndroid13OrAbove() async {
    return Platform.isAndroid && (Platform.version.compareTo('33') >= 0);
  }

  Future<bool> _isAndroid11OrAbove() async {
    return Platform.isAndroid && (Platform.version.compareTo('30') >= 0);
  }
}
