import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/connectivity_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/provider/utility_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/auth_module_screens/welcome_screen.dart';
import 'package:cashxchange/screens/chat_module_screens/chat_screen.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/screens/notefication_module_screens/notification_screen.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_screen.dart';
import 'package:cashxchange/screens/profile_module_screens/user_info_fill.dart';
import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:cashxchange/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          create: (_) => UtilityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MessagingProvider(),
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
          'home_screen': (context) => const MainBody(),
          'notification_screen': (context) => const NotificationScreen(),
          'profile_screen': (context) => const ProfileScreen(),
          'welcome_screen': (context) => const WelcomeScreen(),
          'user_info_screen': (context) => const UserInfoScreen(),
          'chat_screen': (context) => const ChatScreen(),
          'request_screen': (context) => const RaiseRequestScreen(),
        },
        home: const SplashScreen(),
        // home: const WelcomeScreen(),
        // home: const FullMapScreen(),
        // home: RequestSuccessScreen(),
      ),
    );
  }
}
