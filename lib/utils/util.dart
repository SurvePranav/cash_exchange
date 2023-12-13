import 'dart:io';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAppServices {
  // showing snackbar
  static void showSlackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: AppColors.deepGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

// pick image from device
  static Future<File?> pickImage(BuildContext context) async {
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

// Check for Permission
  static Future<bool> checkPermission(
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

// launch url from application
  static void launchAnyUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // show progress dialog
  static showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }
}
