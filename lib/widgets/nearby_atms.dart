import 'dart:convert';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:cashxchange/widgets/nearby_atm_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class NearbyAtmsWidget extends StatefulWidget {
  const NearbyAtmsWidget({super.key});

  @override
  State<NearbyAtmsWidget> createState() => _NearbyAtmsWidgetState();
}

class _NearbyAtmsWidgetState extends State<NearbyAtmsWidget> {
  final List<Map<String, dynamic>> _nearbyAtms = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getNearbyAtms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyConstantWidget();
          } else {
            return NearbyAtmsList(nearbyAtms: _nearbyAtms, onTap: (request) {});
          }
        });
  }

  Future<void> _getNearbyAtms() async {
    List<double> coodrinates =
        await Provider.of<LocationProvider>(context, listen: false)
            .getCurrentLocation();
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${coodrinates[0]},${coodrinates[1]}&radius=1000&type=atm&key=${ApiKey.getMapsApiKey()}';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = jsonDecode(response.body.toString());
    List results = data['results'];
    _nearbyAtms.clear();
    if (response.statusCode == 200) {
      for (Map i in results) {
        _nearbyAtms.add(
          {
            'lat': i['geometry']['location']['lat'],
            'lng': i['geometry']['location']['lng'],
            'name': i['name'],
            'rating': i['rating'],
            'address': i['vicinity'],
            'isOpen': i['opening_hours']['open_now'],
          },
        );
      }
      print("successfully received data");
    } else {
      print("Something went wrong ");
    }
  }
}
