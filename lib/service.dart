// import 'dart:io';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
// import 'package:path_provider/path_provider.dart';

// class VoiceBotService {
//   static const String _baseUrl = 'http://10.0.2.2:5000/process-voice';
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();

//   Future<void> init() async {
//     // Initialize recorder
//     await _recorder.openRecorder();
//     // Optional: initialize player if you want to play back recordings
//     await _player.openPlayer();
//   }

//   Future<String?> startRecording() async {
//     // Request microphone permission
//     if (await Permission.microphone.request() != PermissionStatus.granted) {
//       throw Exception('Microphone permission not granted');
//     }

//     final directory = await getTemporaryDirectory();
//     final path = '${directory.path}/voice_input.wav';

//     await _recorder.startRecorder(
//       toFile: path,
//       codec: Codec.pcm16WAV,
//     );

//     return path;
//   }

//   Future<String?> stopRecording() async {
//     return await _recorder.stopRecorder();
//   }

//   Future<Map<String, dynamic>> sendVoiceFile(File audioFile) async {
//     try {
//       // Create multipart request
//       var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

//       // Get the mime type of the file
//       final mimeType = lookupMimeType(audioFile.path);

//       // Add the file to the request
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           audioFile.path,
//           contentType: MediaType.parse(mimeType ?? 'audio/wav'),
//         ),
//       );

//       // Send the request
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       // Check response
//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'data': response.body,
//         };
//       } else {
//         return {
//           'success': false,
//           'error': 'Failed to process voice: ${response.body}',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Exception occurred: $e',
//       };
//     }
//   }

//   void dispose() {
//     _recorder.closeRecorder();
//     _player.closePlayer();
//   }
// }


import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class VoiceBotService {
  static const String _baseUrl = 'http://10.0.2.2:5000/process-voice';

  // Declare FlutterSound objects
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  // Track recording state
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;

  // Recording settings
  Codec _codec = Codec.pcm16WAV;
  int _sampleRate = 44100;
  int _numChannels = 1;

  Future<void> init() async {
    try {
      // Initialize Recorder
      await _recorder.openRecorder();
      _isRecorderInitialized = true;

      // Configure recorder
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));

      // Initialize Player (optional)
      await _player.openPlayer();
      _isPlayerInitialized = true;

      print('VoiceBotService initialized successfully');
    } catch (e) {
      print('Initialization error: $e');
      throw Exception('Failed to initialize VoiceBotService: $e');
    }
  }

  Future<String?> startRecording() async {
    // Check microphone permission
    var micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    // Ensure recorder is initialized
    if (!_isRecorderInitialized) {
      await init();
    }

    try {
      // Get temporary directory for storing recording
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording
      await _recorder.startRecorder(
        toFile: path,
        codec: _codec,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
      );

      print('Recording started at: $path');
      return path;
    } catch (e) {
      print('Recording start error: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    try {
      // Stop the recorder and get the file path
      final path = await _recorder.stopRecorder();
      print('Recording stopped. File path: $path');
      return path;
    } catch (e) {
      print('Recording stop error: $e');
      throw Exception('Failed to stop recording: $e');
    }
  }

  // Play recorded audio (optional)
  Future<void> playRecording(String path) async {
    if (!_isPlayerInitialized) {
      await _player.openPlayer();
    }

    try {
      await _player.startPlayer(
        fromURI: path,
        codec: _codec,
        whenFinished: () {
          print('Playback finished');
        },
      );
    } catch (e) {
      print('Playback error: $e');
      throw Exception('Failed to play recording: $e');
    }
  }

  Future<Map<String, dynamic>> sendVoiceFile(File audioFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Get the mime type of the file
      final mimeType = lookupMimeType(audioFile.path);

      // Add the file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType.parse(mimeType ?? 'audio/wav'),
        ),
      );

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to process voice: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred: $e',
      };
    }
  }

  void dispose() {
    // Close recorder and player
    _recorder.closeRecorder();
    _player.closePlayer();

    // Reset initialization flags
    _isRecorderInitialized = false;
    _isPlayerInitialized = false;
  }
}
