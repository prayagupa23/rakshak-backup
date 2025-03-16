import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rakshak_backup_final/splashscreen.dart';
import 'package:rakshak_backup_final/welcome_screen.dart';
import 'package:rakshak_backup_final/Features/Feature1.dart'; // Import first feature screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Retrieve installation and login status
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenFeatures = prefs.getBool('hasSeenFeatures') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(hasSeenFeatures: hasSeenFeatures, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool hasSeenFeatures;
  final bool isLoggedIn;

  const MyApp({super.key, required this.hasSeenFeatures, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rakshak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: hasSeenFeatures ? (isLoggedIn ? SplashScreen() : WelcomeScreen()) : Feature1screen(),
    );
  }
}
