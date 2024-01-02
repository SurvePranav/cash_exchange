import 'package:cashxchange/screens/request_module_screens/atm_info_screen.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:cashxchange/widgets/nearby_atm_list.dart';
import 'package:flutter/cupertino.dart';

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
      future: _getNearbyAtms(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyConstantWidget();
        } else {
          return NearbyAtmsList(
            nearbyAtms: _nearbyAtms,
            onTap: (atm) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => AtmInfoScreen(atm: atm),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _getNearbyAtms(BuildContext context) async {
    final List<double> coordinates =
        await LocationServices.getCurrentLocation(context);
    final List results = await LocationServices.getNearbyPlaces(
        lat: coordinates[0], lng: coordinates[1], place: "atm");
    _nearbyAtms.clear();
    for (Map i in results) {
      _nearbyAtms.add(
        {
          'currentLat': coordinates[0],
          'currentLng': coordinates[1],
          'lat': i['geometry']['location']['lat'],
          'lng': i['geometry']['location']['lng'],
          'name': i['name'],
          'rating': i.containsKey('rating') ? i['rating'] : '--',
          'place_id': i['place_id'],
          'photo_reference': i.containsKey('photos')
              ? i['photos'][0]['photo_reference']
              : null,
          'distance': LocationServices.findDistanceBetweenCoordinates(
            coordinates[0],
            coordinates[1],
            i['geometry']['location']['lat'],
            i['geometry']['location']['lng'],
          ),
        },
      );
    }
  }
}
