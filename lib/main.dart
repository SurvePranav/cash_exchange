import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/screens/splash_screen.dart';
import 'package:cashxchange/screens/to_implement/full_map.dart';
import 'package:cashxchange/screens/user_info_fill.dart';
import 'package:cashxchange/utils/local_images.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CashXChange',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.mintGreen,
          primaryIconTheme: IconThemeData(color: AppColors.deepGreen),
          iconTheme: IconThemeData(color: AppColors.deepGreen),
        ),
        routes: {
          'home_screen': (context) => const MainBody(currentIndex: 0),
          'chats_screen': (context) => const MainBody(currentIndex: 1),
          'new_request_screen': (context) => const MainBody(currentIndex: 2),
          'notification_screen': (context) => const MainBody(currentIndex: 3),
          'profile_screen': (context) => const MainBody(currentIndex: 4),
        },
        home: const SplashScreen(),
        // home: const WelcomeScreen(),
        // home: const FullMapScreen(),
        // home: RequestSuccessScreen(),
      ),
    );
  }
}
