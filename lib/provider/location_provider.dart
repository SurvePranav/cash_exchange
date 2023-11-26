import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // find address string from latitude,longitiude

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;
        return "${first.street}, ${first.subLocality}, ${first.locality}, ${first.administrativeArea} ${first.postalCode}, ${first.country}";
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // find latutude, longitude from string

  Future<List<double?>> getCoordinatesFromAddressString(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return [
          locations.first.latitude,
          locations.first.longitude,
        ];
      } else {
        return [];
      }
    } catch (e) {
      print("Error Getting Coordinates: $e");
      return [];
    }
  }

  // for getting current location's latutude, longitude
  Future<List<double>> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location Permission Dissabled");
    }
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

  // filter markers within the 5km radius
  List<Map<String, dynamic>> requestsWithinGivenRadious({
    required double radious,
    required List<Map<String, dynamic>> locations,
    required currentLat,
    required currentLon,
  }) {
    List<Map<String, dynamic>> filtered = [];
    locations.map((e) {
      if (calculateDistance(
            currentLat,
            currentLon,
            double.parse(e['locationLat']),
            double.parse(e['locationLon']),
          ) <=
          radious) {
        filtered.add(e);
      }
    });
    return filtered;
  }

  double calculateDistance(
      double currentLat, double currentLon, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - currentLat);
    final double dLon = _toRadians(lon2 - currentLon);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(currentLat)) *
            cos(_toRadians(currentLon)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
