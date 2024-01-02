import 'dart:convert';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationServices {
  // get the address from location coordinates
  static Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${ApiKey.getMapsApiKey()}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final results = decodedData['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'] as String;
          return formattedAddress;
        } else {
          return "Address not found";
        }
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // for getting current location's latutude, longitude
  static Future<List<double>> getCurrentLocation(BuildContext context) async {
    await Geolocator.isLocationServiceEnabled().then((serviceEnabled) async {
      if (!serviceEnabled) {
        MyAppServices.showSnackBar(context, 'Turn On location');
        return Future.error("Location Not On");
      }
    });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location Permission Denied");
      }
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error("Locatoion Permission denied forever");
    }
    Position pos = await Geolocator.getCurrentPosition();
    return [pos.latitude, pos.longitude];
  }

  // find distance between 2 coordinates
  static double findDistanceBetweenCoordinates(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // get Static map image
  static String getStaticMapUrl({
    required double lat,
    required double lon,
    required int zoom,
    required int width,
    required int height,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=$zoom&size=${width}x$height&key=${ApiKey.getMapsApiKey()}';
  }

  // calculate distance between coordinates
  static Future<Map<String, dynamic>> calculateWalkingDistance({
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

  // get the place images
  static Future<String?> getCurrentLocationPhotoUrl(
      String photoReference) async {
    final photoUrl =
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${ApiKey.getMapsApiKey()}';

    final response = await http.get(Uri.parse(photoUrl));

    if (response.statusCode == 200) {
      return response.request!.url.toString();
    } else {
      return null;
    }
  }

  // get the place details
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${ApiKey.getMapsApiKey()}';

    final response = await http.get(Uri.parse(detailsUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // get nearby places
  static Future<List> getNearbyPlaces(
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
}
