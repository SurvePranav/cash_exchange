import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/screens/notefication_module_screens/notification_screen.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_screen.dart';
import 'package:cashxchange/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
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
          'notification_screen': (context) => NotificationScreen(),
          'profile_screen': (context) => const ProfileScreen(),
        },
        home: const SplashScreen(),
        // home: const WelcomeScreen(),
        // home: const FullMapScreen(),
        // home: RequestSuccessScreen(),
      ),
    );
  }
}
