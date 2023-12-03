import 'dart:convert';
import 'dart:io';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

// launch url from application
void launchAnyUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}

// get nearby places
Future<List> getNearbyPlaces(
    {required double lat, required double lng, required String place}) async {
  String url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=800&type=$place&key=${ApiKey.getMapsApiKey()}';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body.toString());
    return data['results'];
  } else {
    return [];
  }
}

// get the place details
Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
  final detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${ApiKey.getMapsApiKey()}';

  final response = await http.get(Uri.parse(detailsUrl));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

// get the place images
Future<String?> getPhotoUrl(String photoReference) async {
  final photoUrl =
      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${ApiKey.getMapsApiKey()}';

  final response = await http.get(Uri.parse(photoUrl));

  if (response.statusCode == 200) {
    return response.request!.url.toString();
  } else {
    return null;
  }
}

// calculate distance between coordinates
Future<Map<String, dynamic>> calculateWalkingDistance({
  required double originLat,
  required double originLng,
  required double destinationLat,
  required double destinationLng,
}) async {
  final apiUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=walking&origins=$originLat,$originLng&destinations=$destinationLat,$destinationLng&key=${ApiKey.getMapsApiKey()}';
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body.toString());
    final mapped = {
      'destination_address': decodedResponse['destination_addresses'][0],
      'distance_value': decodedResponse['rows'][0]['elements'][0]['distance']
          ['value'],
      'duration_text': decodedResponse['rows'][0]['elements'][0]['duration']
          ['text'],
    };
    return mapped;
  } else {
    return {};
  }
}

// get Static map image
String getStaticMapUrl({
  required double lat,
  required double lon,
  required int zoom,
  required int width,
  required int height,
}) {
  return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=$zoom&size=${width}x$height&key=${ApiKey.getMapsApiKey()}';
}

// get
