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

  // find distance between 2 coordinates
  double findDistanceBetweenCoordinates(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
