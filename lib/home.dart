import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'service.dart';

class VoiceBotScreen extends StatefulWidget {
  const VoiceBotScreen({super.key});

  @override
  _VoiceBotScreenState createState() => _VoiceBotScreenState();
}

class _VoiceBotScreenState extends State<VoiceBotScreen> {
  // final VoiceBotService _voiceBotService = VoiceBotService();
  // FlutterTts? _flutterTts;

  // String _recognizedText = 'Tap the microphone to start recording';
  // String _botResponse = 'Waiting for your voice input';
  // bool _isRecording = false;
  // bool _isProcessing = false;
  // double _recordingProgress = 0.0;
  // List<String> _logs = [];
  // String? _recordingPath; // Add this to store the recording path
  // bool _isPlaying = false; // Add this to track playback state

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeServices();
  // }

  // void _addLog(String message) {
  //   setState(() {
  //     _logs.add(message);
  //     // Keep only the last 5 logs
  //     if (_logs.length > 5) {
  //       _logs.removeAt(0);
  //     }
  //   });
  // }

  // Future<void> _initializeServices() async {
  //   try {
  //     // Initialize TTS
  //     _flutterTts = FlutterTts();
  //     await _flutterTts?.setLanguage('en-US');
  //     await _flutterTts?.setPitch(1.0);
  //     await _flutterTts?.setSpeechRate(0.5);
  //     _addLog('TTS initialized successfully');

  //     // Initialize Voice Bot Service
  //     await _voiceBotService.init();
  //     _addLog('Voice Bot Service initialized');
  //   } catch (e) {
  //     _addLog('Initialization Error: $e');
  //     _showErrorSnackBar('Service Initialization Failed');
  //   }
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  final VoiceBotService _voiceBotService = VoiceBotService();
  FlutterTts? _flutterTts;

  String _recognizedText = 'Tap the microphone to start recording';
  String _botResponse = 'Waiting for your voice input';
  bool _isRecording = false;
  bool _isProcessing = false;
  double _recordingProgress = 0.0;
  List<String> _logs = [];
  String? _recordingPath; // Add this to store the recording path
  bool _isPlaying = false; // Add this to track playback state

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
      // Keep only the last 5 logs
      if (_logs.length > 5) {
        _logs.removeAt(0);
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize TTS
      _flutterTts = FlutterTts();
      await _flutterTts?.setLanguage('en-US');
      await _flutterTts?.setPitch(1.0);
      await _flutterTts?.setSpeechRate(0.5);
      _addLog('TTS initialized successfully');

      // Initialize Voice Bot Service
      await _voiceBotService.init();
      _addLog('Voice Bot Service initialized');
    } catch (e) {
      _addLog('Initialization Error: $e');
      _showErrorSnackBar('Service Initialization Failed');
    }
  }


    Future<void> _startRecording() async {
    try {
      final recordingPath = await _voiceBotService.startRecording();
      _addLog('Recording started at: $recordingPath');

      setState(() {
        _isRecording = true;
        _recordingPath = recordingPath; // Store the recording path
        _recognizedText = 'Recording in progress...';
        _recordingProgress = 0.0;
      });

      // Simulate recording progress
      Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 500));
        if (!_isRecording) return false;

        setState(() {
          _recordingProgress += 0.1;
          if (_recordingProgress > 1.0) _recordingProgress = 0.0;
        });
        return _isRecording;
      });
    } catch (e) {
      _addLog('Recording Start Error: $e');
      _showErrorSnackBar('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _voiceBotService.stopRecording();
      _addLog('Recording stopped. File path: $path');

      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _recordingPath = path; // Update recording path
        _recognizedText = 'Processing audio...';
        _recordingProgress = 0.0;
      });

      if (path != null) {
        final response = await _voiceBotService.sendVoiceFile(File(path));
        _addLog('API Response: ${response['success']}');

        setState(() {
          _isProcessing = false;
          if (response['success']) {
            _recognizedText = response['data']['text'] ?? 'No text recognized';
            _botResponse = response['data']['response'] ?? 'No response';
            _addLog('Text Recognized: $_recognizedText');
            _addLog('Bot Response: $_botResponse');
          } else {
            _botResponse = response['error'] ?? 'Unknown error';
            _addLog('Error: $_botResponse');
          }
        });

        // Speak the response
        await _flutterTts?.speak(_botResponse);
      }
    } catch (e) {
      _addLog('Recording Stop Error: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _botResponse = 'Error: $e';
      });
      _showErrorSnackBar('Failed to process recording');
    }
  }

  // Method to play recorded audio
  Future<void> _playRecording() async {
    if (_recordingPath != null) {
      try {
        setState(() {
          _isPlaying = true;
        });

        await _voiceBotService.playRecording(_recordingPath!);
        _addLog('Playing recorded audio');

        setState(() {
          _isPlaying = false;
        });
      } catch (e) {
        setState(() {
          _isPlaying = false;
        });
        _addLog('Playback error: $e');
        _showErrorSnackBar('Failed to play recording');
      }
    } else {
      _showErrorSnackBar('No recording available to play');
    }
  }

  // Future<void> _startRecording() async {
  //   try {
  //     final recordingPath = await _voiceBotService.startRecording();
  //     _addLog('Recording started at: $recordingPath');

  //     setState(() {
  //       _isRecording = true;
  //       _recognizedText = 'Recording in progress...';
  //       _recordingProgress = 0.0;
  //     });

  //     // Simulate recording progress
  //     Future.doWhile(() async {
  //       await Future.delayed(Duration(milliseconds: 500));
  //       if (!_isRecording) return false;

  //       setState(() {
  //         _recordingProgress += 0.1;
  //         if (_recordingProgress > 1.0) _recordingProgress = 0.0;
  //       });
  //       return _isRecording;
  //     });
  //   } catch (e) {
  //     _addLog('Recording Start Error: $e');
  //     _showErrorSnackBar('Failed to start recording');
  //   }
  // }

  // Future<void> _stopRecording() async {
  //   try {
  //     final path = await _voiceBotService.stopRecording();
  //     _addLog('Recording stopped. File path: $path');

  //     setState(() {
  //       _isRecording = false;
  //       _isProcessing = true;
  //       _recognizedText = 'Processing audio...';
  //       _recordingProgress = 0.0;
  //     });

  //     if (path != null) {
  //       final response = await _voiceBotService.sendVoiceFile(File(path));
  //       _addLog('API Response: ${response['success']}');

  //       setState(() {
  //         _isProcessing = false;
  //         if (response['success']) {
  //           _recognizedText = response['data']['text'] ?? 'No text recognized';
  //           _botResponse = response['data']['response'] ?? 'No response';
  //           _addLog('Text Recognized: $_recognizedText');
  //           _addLog('Bot Response: $_botResponse');
  //         } else {
  //           _botResponse = response['error'] ?? 'Unknown error';
  //           _addLog('Error: $_botResponse');
  //         }
  //       });

  //       // Speak the response
  //       await _flutterTts?.speak(_botResponse);
  //     }
  //   } catch (e) {
  //     _addLog('Recording Stop Error: $e');
  //     setState(() {
  //       _isRecording = false;
  //       _isProcessing = false;
  //       _botResponse = 'Error: $e';
  //     });
  //     _showErrorSnackBar('Failed to process recording');
  //   }
  // }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(100),
            colors: [
              const Color.fromARGB(255, 199, 226, 248)!,
              const Color.fromARGB(255, 120, 194, 255)!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Nexi',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Recognition Status
                      _buildStatusCard('Recognized Text', _recognizedText,
                          Icons.record_voice_over, Colors.blue[700]!),
                      const SizedBox(height: 16),

                      // Bot Response
                      _buildStatusCard('Bot Response', _botResponse,
                          Icons.chat_bubble_outline, Colors.green[700]!),
                      const SizedBox(height: 16),

                      // Progress Indicator
                      if (_isRecording || _isProcessing)
                        LinearProgressIndicator(
                          value: _recordingProgress,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),

                      // Logs Section
                      SizedBox(height: 16),
                      Text(
                        'Logs',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Text(
                              _logs[index],
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Record Button
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: ElevatedButton.icon(
              //     onPressed: _isRecording ? _stopRecording : _startRecording,
              //     icon: Icon(
              //       _isRecording ? Icons.stop : Icons.mic_rounded,
              //       color: Colors.white,
              //       size: 25,
              //     ),
              //     label: Text(
              //       _isRecording ? 'Stop Recording' : 'Start Recording',
              //       style: GoogleFonts.poppins(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor:
              //           _isRecording ? Colors.red : Colors.blue[300],
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 32, vertical: 12),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  borderRadius:
                      BorderRadius.circular(30), // Keep the same border radius
                  elevation: 4, // Adds shadow effect
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isRecording
                            ? [Colors.red, Colors.redAccent]
                            : [
                                const Color.fromARGB(255, 132, 196, 248),
                                Colors.blue
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton.icon(
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.mic_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        _isRecording ? 'Stop Recording' : 'Start Recording',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Important for gradient effect
                        shadowColor:
                            Colors.transparent, // Removes shadow under button
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceBotService.dispose();
    _flutterTts?.stop();
    super.dispose();
  }
}
