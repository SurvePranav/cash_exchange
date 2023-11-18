import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Widget _myWidget = const Icon(
    Icons.location_searching,
  );
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setWidgetToLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      _myWidget = const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 1,
      );
      notifyListeners();
    } else {
      _isLoading = false;
      _myWidget = const Icon(
        Icons.location_searching,
        color: Colors.white,
      );
      notifyListeners();
    }
  }

  Widget get myWidget => _myWidget;
  // find address from query
  Future<List> getAddressFromQuery(String address) async {
    return await Geocoder.local.findAddressesFromQuery(address);
  }

  // find address from coordinates
  Future<List> getAddressFromCoordinates(Coordinates coordinates) async {
    return await Geocoder.local.findAddressesFromCoordinates(coordinates);
  }

  // for getting current location
  Future<Position> getCurrentLocation() async {
    setWidgetToLoading(true);
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
    var pos = await Geolocator.getCurrentPosition();
    setWidgetToLoading(false);
    return pos;
  }
}
