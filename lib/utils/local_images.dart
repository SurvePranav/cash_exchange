import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageSingleton {
  // Static field to store local image path
  static String? _localImagePath;

  // Getter for the local image path
  static String? get localImagePath => _localImagePath;
  static int _i = 1;

  // Function to set image from a given URL
  static Future<void> setImageFromUrl(String imageUrl) async {
    try {
      await getDataFromSP();
      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get the application documents directory
        final appDir = await getApplicationDocumentsDirectory();

        // Create a destination path in the application documents directory
        final destinationPath = "${appDir.path}/profile_pic$_i.jpg";

        // Write the downloaded image to the destination path
        final File file = File(destinationPath);
        await file.writeAsBytes(response.bodyBytes);

        // Set the local image path
        _localImagePath = destinationPath;
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  // Method to set the local image from path
  static Future<void> setLocalImagePath({required String imagePath}) async {
    await getDataFromSP();
    // Get the application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    // Create a destination path in the application documents directory
    final destinationPath = "${appDir.path}/profile_pic$_i.jpg";
    // Copy the picked image to the destination path
    try {
      await File(imagePath).copy(destinationPath);
      _localImagePath = destinationPath;
      return;
    } catch (e) {
      return;
    }
  }

  // Function to get the locally stored image as a File
  static File? getLocalImage() {
    if (_localImagePath != null) {
      return File(_localImagePath!);
    }
    return null;
  }

  // Function to delete the locally stored image
  static Future<void> deleteLocalImage() async {
    try {
      if (_localImagePath != null) {
        final file = File(_localImagePath!);
        if (await file.exists()) {
          await file.delete();
          _i = _i + 1;
          final appDir = await getApplicationDocumentsDirectory();
          await saveDataToSP("${appDir.path}/profile_pic$_i.jpg", _i);
        }
        // Reset the local image path
        _localImagePath = null;
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  static Future saveDataToSP(String localImagePath, int i) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString(
      "local_image",
      jsonEncode({'localImagePath': localImagePath, 'i': i}),
    );
  }

  // Get Data From local (shared preference)
  static Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    if (s.getString("local_image") != null) {
      String data = s.getString("local_image")!;
      Map mappedData = jsonDecode(data);
      _localImagePath = mappedData['localImagePath'];
      _i = mappedData['i'] ?? 1;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      // Create a destination path in the application documents directory
      final localImagePath = "${appDir.path}/profile_pic1.jpg";
      await saveDataToSP(localImagePath, 1);
    }
  }
}
