import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'permission_manager.dart';

class FileHandler {
  static final PermissionManager permissionManager = PermissionManager();

  // Pick an image or video from the gallery
  static Future<XFile?> pickImageOrVideo() async {
    bool hasGalleryPermission =
        await permissionManager.checkAndRequestFilePermission();

    if (hasGalleryPermission) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        return pickedFile;
      }
    } else {}
    return null;
  }

  // Handle camera permission and open camera
  static Future<XFile?> openCamera() async {
    bool hasCameraPermission =
        await permissionManager.checkAndRequestCameraPermission();

    if (hasCameraPermission) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        return pickedFile;
      }
    } else {}
    return null;
  }

  // Method to open gallery or camera selection
  static Future<XFile?> openGalleryOrCameraSelection(
    BuildContext context,
  ) async {
    final Completer<XFile?> completer = Completer<XFile?>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // 👈 Add bottom padding here
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final file = await pickImageOrVideo();
                    completer.complete(file);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final file = await openCamera();
                    completer.complete(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}
