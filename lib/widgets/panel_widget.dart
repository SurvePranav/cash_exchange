import 'package:flutter/material.dart';

class PanelWidget extends StatelessWidget {
  final ScrollController controller;
  const PanelWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(
          height: 30,
        ),
        buildInfoCard(),
      ],
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: const Column(children: [
        Text(
          "About",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        SizedBox(
          height: 23,
        ),
        Text(
            '''PS P:Final_Year_Projectcashxchange> flutter pub add sliding_up_panel
Resolving dependencies...
  _flutterfire_internals 1.3.4 (1.3.13 available)
  cloud_firestore 4.8.4 (4.13.2 available)
  cloud_firestore_platform_interface 5.15.3 (6.0.6 available)
  cloud_firestore_web 3.6.3 (3.8.6 available)
  collection 1.17.1 (1.18.0 available)
  country_picker 2.0.20 (2.0.22 available)
  cross_file 0.3.3+4 (0.3.3+7 available)
  cupertino_icons 1.0.5 (1.0.6 available)
  ffi 2.0.2 (2.1.0 available)
  file 6.1.4 (7.0.0 available)
  file_selector_linux 0.9.2 (0.9.2+1 available)
  file_selector_macos 0.9.3+1 (0.9.3+3 available)
  file_selector_platform_interface 2.6.0 (2.6.1 available)
  file_selector_windows 0.9.3 (0.9.3+1 available)
  firebase_auth 4.7.2 (4.14.1 available)
  firebase_auth_platform_interface 6.16.1 (7.0.5 available)
  firebase_auth_web 5.6.2 (5.8.8 available)
  firebase_core 2.15.0 (2.23.0 available)
  firebase_core_platform_interface 4.8.0 (5.0.0 available)
  firebase_core_web 2.6.0 (2.8.1 available)
  firebase_storage 11.2.5 (11.5.2 available)
  firebase_storage_platform_interface 4.4.4 (5.1.0 available)
  firebase_storage_web 3.6.5 (3.6.14 available)
  flutter_lints 2.0.2 (3.0.1 available)
  flutter_plugin_android_lifecycle 2.0.15 (2.0.17 available)
  geocoding_platform_interface 2.0.1 (3.1.0 available)
  geolocator_platform_interface 4.1.0 (4.2.0 available)
  google_maps_flutter_web 0.5.4+1 (0.5.4+2 available)
  http 1.1.0 (1.1.1 available)
  image_picker 1.0.1 (1.0.4 available)
  image_picker_android 0.8.7+4 (0.8.8+2 available)
  image_picker_for_web 2.2.0 (3.0.1 available)
  image_picker_ios 0.8.8 (0.8.8+4 available)
  image_picker_linux 0.2.1 (0.2.1+1 available)
  image_picker_macos 0.2.1 (0.2.1+1 available)
  image_picker_platform_interface 2.9.0 (2.9.1 available)
  image_picker_windows 0.2.1 (0.2.1+1 available)
  lints 2.1.1 (3.0.0 available)
  matcher 0.12.15 (0.12.16 available)
  material_color_utilities 0.2.0 (0.8.0 available)
  meta 1.9.1 (1.11.0 available)
  path_provider_linux 2.1.11 (2.2.1 available)
  path_provider_platform_interface 2.0.6 (2.1.1 available)
  path_provider_windows 2.1.7 (2.2.1 available)
  permission_handler 10.4.3 (11.1.0 available)
  permission_handler_android 10.3.3 (12.0.1 available)
  permission_handler_apple 9.1.4 (9.2.0 available)
  permission_handler_platform_interface 3.11.3 (4.0.2 available)
  permission_handler_windows 0.1.3 (0.2.0 available)
  pinput 2.3.0 (3.0.1 available)
  platform 3.1.0 (3.1.3 available)
  plugin_platform_interface 2.1.5 (2.1.7 available)
  provider 6.0.5 (6.1.1 available)
  shared_preferences 2.2.0 (2.2.2 available)
  shared_preferences_android 2.2.0 (2.2.1 available)
  shared_preferences_foundation 2.3.2 (2.3.4 available)
  shared_preferences_linux 2.3.0 (2.3.2 available)
  shared_preferences_platform_interface 2.3.0 (2.3.1 available)
  shared_preferences_web 2.2.0 (2.2.2 available)
  shared_preferences_windows 2.3.0 (2.3.2 available)
+ sliding_up_panel 2.0.0+1
  source_span 1.9.1 (1.10.0 available)
  stack_trace 1.11.0 (1.11.1 available)
  stream_channel 2.1.1 (2.1.2 available)
  test_api 0.5.1 (0.6.1 available)
  win32 5.0.6 (5.1.0 available)
  xdg_directories 1.0.1 (1.0.3 available)
Changed 1 dependency!
The plugin `flutter_geocoder` uses a deprecated version of the Android embild failures, try to see if this plugin supports the Android V2 embedding.

Otherwise, consider removing it since a future release of Flutter will remove these deprecated APIs.
If you are plugin author, take a look at the docs for migrating the plugin to the V2 embedding:
https://flutter.dev/go/android-plugin-migration.
PS P:Final_Year_Projectcashxchange>'''),
      ]),
    );
  }
}
