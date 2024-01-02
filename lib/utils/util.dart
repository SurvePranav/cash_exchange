import 'dart:developer';
import 'dart:io';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAppServices {
  // showing snackbar
  static void showSnackBar(BuildContext context, String content,
      {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: bgColor ?? AppColors.deepGreen,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 1),
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
      log('failed to pick image: $e');
    }

    return image;
  }

  // show alert dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.deepGreen),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on continue
              },
              child: Text(
                'Yes',
                style: TextStyle(color: AppColors.deepGreen),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      // User pressed Continue
      return true;
    } else {
      return false;
    }
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
  static void launchAnyUrl(String url, BuildContext context,
      {bool makeACall = false}) async {
    final uri = makeACall
        ? Uri(
            scheme: 'tel',
            path: url,
          )
        : Uri.parse(url);
    log('url to launch: ${uri.toString()}');
    await canLaunchUrl(uri).then((canLaunch) async {
      if (canLaunch) {
        await launchUrl(uri);
      } else {
        showSnackBar(context, 'could not launch');
      }
    });
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
