import 'package:flutter/material.dart';
import 'package:rakshak_backup_final/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../customButton.dart';
import 'package:rakshak_backup_final/sign_in.dart'; // Import Login Screen

class Feature3screen extends StatefulWidget {
  const Feature3screen({super.key});

  @override
  State<Feature3screen> createState() => _Feature3screenState();
}

class _Feature3screenState extends State<Feature3screen> {
  Future<void> _completeFeaturesAndProceed(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenFeatures', true); // Mark Features as Seen

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()), // Move to Login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/maps.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Safe & Dangerous Area Mapping",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "View safe and high-risk zones on a map to avoid dangerous areas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context); // Go to the previous screen
                    },
                    text: "Previous",
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: CustomButton(
                    onPressed: () => _completeFeaturesAndProceed(context), // Proceed to Login
                    text: "Next",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
