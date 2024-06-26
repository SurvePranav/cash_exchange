import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class AppColors {
  static Color blue_10 = const Color(0xff0E1963);
  static Color blue_8 = const Color.fromARGB(255, 11, 45, 166);
  static Color blue_6 = const Color(0xff018abd);
  static Color blue_4 = const Color(0xff97cbdc);
  static Color blue_2 = const Color(0xffdde8f0);

  static Color deepGreen = const Color(0xff19747E);
  static Color mintGreen = const Color(0xffD1E8E2);
  static Color skyBlue = const Color(0xff97cbdc);
  static Color lightMintGreen = const Color(0xffdde8f0);
  static Color lightGrey = const Color(0xffE2E2E2);
  static Color pureWhite = const Color(0xffffffff);
  static Color darkBlack = const Color.fromARGB(255, 0, 0, 0);
  static Color dimBlack = const Color.fromARGB(120, 0, 0, 0);
}

class ApiKey {
  static String getMapsApiKey() {
    const androidKey = "abc";
    const iosKey = "abc";
    const webKey = "abc";
    if (Platform.isAndroid) {
      return androidKey;
    } else if (Platform.isIOS) {
      return iosKey;
    } else if (kIsWeb) {
      return webKey;
    } else {
      return androidKey;
    }
  }
}
