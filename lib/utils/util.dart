import 'dart:io';
import 'dart:typed_data';

import 'package:cashxchange/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void showSlackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: AppColors.deepGreen,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// pick image from device
Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSlackBar(context, e.toString());
  }

  return image;
}

// compress image size
Future<File?> compressImage(File originalImage, String path) async {
  try {
    Uint8List? imageBytes = await FlutterImageCompress.compressWithFile(
      path,
      // minWidth: 1024, // Set the minimum width (optional)
      // minHeight: 1024, // Set the minimum height (optional)
      quality: 60, // Set the quality (0 - 100)
    );

    // Create a new File from the compressed bytes
    if (imageBytes != null) {
      File compressedImage = File.fromRawPath(imageBytes);
      return compressedImage;
    } else {
      // print("got null image");
      return null;
    }
  } catch (e) {
    // print("Error compressing image: $e");
    return null;
  }
}

// Check Permission
Future<bool> checkPermission(
    Permission permission, BuildContext context) async {
  final PermissionStatus status = await permission.request();
  if (status.isGranted) {
    // Permission granted
    // You can now access the photos
    return status.isGranted;
  } else if (status.isDenied) {
    // Permission denied
    bool showRationale = await Permission.photos.shouldShowRequestRationale;
    if (!showRationale) {
      // The user denied permission and selected "Don't ask again"
      // You can show a dialog explaining the importance of the permission
      // and guide the user to app settings to enable the permission
      return !showRationale;
    }
  }
  return status.isGranted;
}
