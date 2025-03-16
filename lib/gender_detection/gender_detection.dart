import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:photo_analyzer/photo_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rakshak_backup_final/splashscreen.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasVerifiedGender = prefs.getBool('hasVerifiedGender') ?? false;

  runApp(MyApp(hasVerifiedGender: hasVerifiedGender));
}

class MyApp extends StatelessWidget {
  final bool hasVerifiedGender;

  const MyApp({super.key, required this.hasVerifiedGender});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gender Classification App',
      home: hasVerifiedGender ? SplashScreen() : GenderVerification(),
    );
  }
}

class GenderVerification extends StatelessWidget {
  const GenderVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  CameraController? cameraController;
  String? capturedImagePath;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  Future<void> _setupCameraController() async {
    try {
      // Request camera permission
      var status = await Permission.camera.request();

      if (status != PermissionStatus.granted) {
        debugPrint("Camera permission denied.");
        return;
      }

      // Ensure cameras list is initialized
      if (cameras == null || cameras!.isEmpty) {
        debugPrint("No cameras available.");
        return;
      }

      debugPrint("Initializing camera...");
      cameraController = CameraController(
        cameras!.first, // Use first camera
        ResolutionPreset.high,
        enableAudio: false, // Disable audio for better performance
      );

      // Attempt to initialize camera
      await cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }

      debugPrint("Camera initialized successfully.");
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }



  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return const Center(child: Text("Error: Camera not found."));
    }

    if (!cameraController!.value.isInitialized) {
      return const Center(child: Text("Initializing Camera... Please wait"));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Image.asset('assets/redbull.png', width: 100, height: 100),
                Text(
                  "Because every detail matters...",
                  style: GoogleFonts.comfortaa(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            ClipOval(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.9,
                child: CameraPreview(cameraController!),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.pink),
                      onPressed: () async {
                        try {
                          final XFile imageFile = await cameraController!.takePicture();
                          setState(() {
                            capturedImagePath = imageFile.path;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Picture captured successfully!')),
                          );
                        } catch (e) {
                          debugPrint('Error capturing image: $e');
                        }
                      },
                    ),
                    Text("Take Picture", style: GoogleFonts.comfortaa(fontSize: 12, color: Colors.pinkAccent)),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.arrow_circle_right_rounded, color: Colors.pink),
                      onPressed: () {
                        if (capturedImagePath != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(imagePath: capturedImagePath!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please take a picture first!')),
                          );
                        }
                      },
                    ),
                    Text("Next", style: GoogleFonts.comfortaa(fontSize: 12, color: Colors.pinkAccent)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _photoAnalyzerPlugin = PhotoAnalyzer();
  String _genderResult = "Verifying gender...";

  @override
  void initState() {
    super.initState();
    _detectGender();
  }

  Future<void> _detectGender() async {
    setState(() {
      _genderResult = "Verifying gender...";
    });

    try {
      debugPrint("Reading image file: ${widget.imagePath}");
      final imageBytes = await File(widget.imagePath).readAsBytes();
      debugPrint("Image file read successfully.");

      debugPrint("Calling gender prediction...");
      final result = await _photoAnalyzerPlugin.genderPrediction(image: imageBytes);
      debugPrint("Gender prediction result: $result");

      if (mounted) {
        setState(() {
          _genderResult = result.toString();
        });
      }
    } catch (e) {
      debugPrint("Error in gender detection: $e");
      if (mounted) {
        setState(() {
          _genderResult = "Error detecting gender: $e";
        });
      }
    }
  }


  Future<void> _markGenderVerifiedAndProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasVerifiedGender', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify your gender...",
          style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ClipOval(
              child: Image.file(
                File(widget.imagePath),
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, minimumSize: const Size(80, 50)),
                  onPressed: () async {
                    await _detectGender();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gender: $_genderResult")),
                    );
                  },
                  child: Text("Verify Gender", style: GoogleFonts.comfortaa(fontSize: 15, color: Colors.white)),
                ),
                const SizedBox(height: 25),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_right_rounded, color: Colors.pink),
                      iconSize: 70,
                      onPressed: () async {
                        if (_genderResult.toLowerCase() == 'female') {
                          await _markGenderVerifiedAndProceed();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gender is not female. Cannot proceed.")),
                          );
                        }
                      },
                    ),
                    Text("Proceed", style: GoogleFonts.comfortaa(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.pink)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
