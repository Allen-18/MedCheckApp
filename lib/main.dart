import 'package:practice/screens/arduino_screen.dart';
import 'package:practice/screens/calendar.dart';
import 'package:practice/screens/login.dart';
import 'package:practice/screens/menu.dart';
import 'package:practice/screens/profile.dart';
import 'package:practice/screens/reference_pacient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android App',
      initialRoute: '/menuApp',
      routes: {
        '/login': (context) => const LoginPage(),
        '/menuApp': (context) => const MenuScreen(
              access: null,
              refresh: null,
            ),
        '/profilePatient': (context) => const ProfileScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/recommendations': (context) => const ReferenceScreen(),
         '/connectArduino': (context) => const ArduinoScreen(),
        // '/graphics': (context) => const GraphicsScreen(),
      },
      theme: ThemeData.dark(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          ),
    );
  }
}
