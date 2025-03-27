import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_bot_apk/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter plugins are initialized
  runApp(const MyApp());

  FlutterTts tts = FlutterTts();
  List<dynamic>? voices;

  try {
    voices = await tts.getVoices;
    print("Available Voices: $voices");
  } catch (e) {
    print("Error fetching voices: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Bots',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VoiceBotScreen(),
    );
  }
}
