import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/screens/request_module_screens/full_map.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMapWidget extends StatefulWidget {
  const ViewMapWidget({super.key});

  @override
  State<ViewMapWidget> createState() => _ViewMapWidgetState();
}

class _ViewMapWidgetState extends State<ViewMapWidget> {
  Widget? cachedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            height: MediaQuery.of(context).size.height * 0.23,
            child: FutureBuilder(
              future: Provider.of<LocationProvider>(context, listen: false)
                  .getCurrentLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  cachedImage = ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      getStaticMapUrl(
                        apiKey: ApiKey.getMapsApiKey(),
                        lat: snapshot.data![0],
                        lon: snapshot.data![1],
                        zoom: 17,
                        width: 400,
                        height:
                            (MediaQuery.of(context).size.height * 0.26).toInt(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                  return Stack(
                    children: [
                      Align(alignment: Alignment.center, child: cachedImage!),
                      Align(
                        alignment: const Alignment(0, -0.40),
                        child: Icon(
                          Icons.location_pin,
                          color: AppColors.blue_4,
                          size: 64,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text("."),
                      ),
                      Align(
                        alignment: const Alignment(0, -0.42),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black,
                          backgroundImage:
                              NetworkImage(UserModel.instance.profilePic),
                        ),
                      ),
                    ],
                  );
                } else {
                  if (cachedImage != null) {
                    return cachedImage!;
                  } else {
                    return Center(
                      child: LinearProgressIndicator(
                        color: AppColors.deepGreen,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const FullMapScreen(),
              ));
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white, // Change the text color
              padding: const EdgeInsets.all(16.0), // Change padding
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20.0), // Change button shape
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: AppColors.deepGreen,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  'View On Map',
                  style: TextStyle(color: AppColors.deepGreen),
                ),
                const Expanded(child: SizedBox()),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.deepGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getStaticMapUrl({
    required String apiKey,
    required double lat,
    required double lon,
    required int zoom,
    required int width,
    required int height,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=$zoom&size=${width}x$height&key=AIzaSyD1LUJFCbES2C3MRDvq4L0eXSf-hJGlY70';
  }
}
