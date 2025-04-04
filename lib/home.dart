// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:voice_bot_apk/service.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import 'dart:math' as math;

// class VoiceBotScreen extends StatefulWidget {
//   const VoiceBotScreen({super.key});

//   @override
//   _VoiceBotScreenState createState() => _VoiceBotScreenState();
// }

// class _VoiceBotScreenState extends State<VoiceBotScreen>
//     with SingleTickerProviderStateMixin {
//   final VoiceBotService _voiceBotService = VoiceBotService();

//   String _recognizedText = 'Tap the microphone to start recording';
//   String _botResponse = 'Waiting for your voice input';
//   bool _isRecording = false;
//   bool _isProcessing = false;
//   double _recordingProgress = 0.0;
//   List<String> _logs = [];
//   String? _recordingPath;

//   // Animation related variables
//   late AnimationController _animationController;
//   List<double> _soundWaves = List.generate(8, (_) => 0.0);
//   Timer? _waveTimer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();

//     // Initialize animation controller
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _addLog(String message) {
//     setState(() {
//       _logs.add("${DateTime.now().toString().substring(11, 19)}: $message");
//       if (_logs.length > 10) {
//         _logs.removeAt(0);
//       }
//     });
//   }

//   Future<void> _initializeServices() async {
//     try {
//       await _voiceBotService.init();
//       _addLog('Voice Bot Service initialized');
//     } catch (e) {
//       _addLog('Initialization Error: $e');
//       _showErrorSnackBar('Service Initialization Failed');
//     }
//   }

//   void _updateWaveAnimation() {
//     // Cancel existing timer if any
//     _waveTimer?.cancel();

//     if (_isRecording) {
//       // Generate random wave heights when recording
//       _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
//         if (mounted) {
//           setState(() {
//             _soundWaves = List.generate(
//               8,
//               (_) =>
//                   _isRecording ? math.Random().nextDouble() * 0.8 + 0.2 : 0.0,
//             );
//           });
//         }
//       });
//     } else {
//       // Reset waves when not recording
//       setState(() {
//         _soundWaves = List.generate(8, (_) => 0.0);
//       });
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       final recordingPath = await _voiceBotService.startRecording();
//       _addLog('Recording started');

//       setState(() {
//         _isRecording = true;
//         _recordingPath = recordingPath;
//         _recognizedText = 'Recording in progress...';
//         _recordingProgress = 0.0;
//       });

//       // Start wave animation
//       _updateWaveAnimation();

//       Future.doWhile(() async {
//         await Future.delayed(Duration(milliseconds: 100));
//         if (!_isRecording) return false;

//         setState(() {
//           _recordingProgress += 0.05;
//           if (_recordingProgress > 1.0) _recordingProgress = 0.0;
//         });
//         return _isRecording;
//       });
//     } catch (e) {
//       _addLog('Recording Start Error: $e');
//       _showErrorSnackBar('Failed to start recording');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final path = await _voiceBotService.stopRecording();
//       _addLog('Recording stopped');

//       setState(() {
//         _isRecording = false;
//         _isProcessing = true;
//         _recordingPath = path;
//         _recognizedText = 'Processing audio...';
//         _recordingProgress = 0.0;
//       });

//       // Update wave animation (stop it)
//       _updateWaveAnimation();

//       if (path != null) {
//         final response = await _voiceBotService.sendVoiceFile(File(path));
//         _addLog('API Response received');

//         setState(() {
//           _isProcessing = false;
//           if (response['success']) {
//             var responseData = response['data'];

//             if (responseData is String) {
//               try {
//                 Map<String, dynamic> parsedData =
//                     jsonDecode(responseData) as Map<String, dynamic>;

//                 _recognizedText = parsedData['text'] ?? 'No text recognized';
//                 _botResponse = parsedData['response'] ?? 'No response';
//               } catch (e) {
//                 _botResponse = 'Error parsing response: $e';
//               }
//             } else if (responseData is Map) {
//               _recognizedText = responseData['text'] ?? 'No text recognized';
//               _botResponse = responseData['response'] ?? 'No response';
//             }

//             _addLog('Text Recognized: $_recognizedText');
//             _addLog('Bot Response: $_botResponse');
//           } else {
//             _botResponse = response['error'] ?? 'Unknown error';
//             _addLog('Error: $_botResponse');
//           }
//         });
//       }
//     } catch (e) {
//       _addLog('Recording Stop Error: $e');
//       setState(() {
//         _isRecording = false;
//         _isProcessing = false;
//         _botResponse = 'Error: $e';
//       });
//       _showErrorSnackBar('Failed to process recording');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.white,
//               Color.fromRGBO(255, 134, 225, .7),
//               Color.fromRGBO(94, 159, 243, 1),
//             ],
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//               Text(
//                 'Nexi',
//                 style: GoogleFonts.poppins(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   foreground: Paint()
//                     ..shader = const LinearGradient(
//                       colors: <Color>[
//                         Color(0xFF8A65FF),
//                         Color(0xFF60A9F6),
//                       ],
//                     ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
//                 ),
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'Ask Nexi anything',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child:
//                       _recognizedText != 'Tap the microphone to start recording'
//                           ? Container(
//                               margin: EdgeInsets.all(20),
//                               padding: EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 6,
//                                     offset: Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Text(
//                                 _recognizedText,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink(),
//                 ),
//               ),
//               // Siri-like animated microphone button
//               GestureDetector(
//                 onTap: _isProcessing
//                     ? null
//                     : (_isRecording ? _stopRecording : _startRecording),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Pulsating rings when recording
//                     if (_isRecording)
//                       ...List.generate(
//                         3,
//                         (index) => AnimatedBuilder(
//                           animation: _animationController,
//                           builder: (context, child) {
//                             final double value = math.max(
//                               0.0,
//                               1.0 -
//                                   (((_animationController.value +
//                                               (index * 0.33)) %
//                                           1.0) *
//                                       1.5),
//                             );

//                             return Container(
//                               width: 70 + (60 * (1 - value)),
//                               height: 70 + (60 * (1 - value)),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.blue.withOpacity(0.3 * value),
//                               ),
//                             );
//                           },
//                         ),
//                       ),

//                     // Sound waves visualization
//                     if (_isRecording)
//                       SizedBox(
//                         width: 140,
//                         height: 140,
//                         child: CustomPaint(
//                           painter: SoundWavePainter(
//                             waveHeights: _soundWaves,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ),

//                     // Main button
//                     Container(
//                       margin: EdgeInsets.only(bottom: 40),
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [
//                             Color.fromRGBO(255, 134, 225, 1),
//                             Color(0xFF81D4FA)
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.blueAccent.withOpacity(0.1),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           )
//                         ],
//                       ),
//                       child: _isProcessing
//                           ? const Center(
//                               child: SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             )
//                           : Icon(
//                               _isRecording ? Icons.stop : Icons.mic,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _voiceBotService.dispose();
//     _animationController.dispose();
//     _waveTimer?.cancel();
//     super.dispose();
//   }
// }

// // Custom painter for the sound wave effect
// class SoundWavePainter extends CustomPainter {
//   final List<double> waveHeights;
//   final Color color;

//   SoundWavePainter({
//     required this.waveHeights,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round;

//     final double center = size.width / 2;
//     final double radius = size.width / 2 - 10;

//     for (int i = 0; i < waveHeights.length; i++) {
//       final double angle = (i / waveHeights.length) * 2 * math.pi;
//       final double waveHeight = waveHeights[i] * 20;

//       // Draw lines from edge of circle toward center
//       final double startX = center + (radius - waveHeight) * math.cos(angle);
//       final double startY = center + (radius - waveHeight) * math.sin(angle);
//       final double endX = center + radius * math.cos(angle);
//       final double endY = center + radius * math.sin(angle);

//       canvas.drawLine(
//         Offset(startX, startY),
//         Offset(endX, endY),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(SoundWavePainter oldDelegate) => true;
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_bot_apk/service.dart';
import 'dart:math' as math;
import 'dart:io';

// Import the VoiceBotService
// import 'voice_bot_service.dart';

class VoiceBotScreen extends StatefulWidget {
  const VoiceBotScreen({super.key});

  @override
  _VoiceBotScreenState createState() => _VoiceBotScreenState();
}

class _VoiceBotScreenState extends State<VoiceBotScreen>
    with TickerProviderStateMixin {
  String _recognizedText = 'Tap the bubble to start recording';
  String _botResponse = 'Waiting for your voice input';
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isExpanded = false;

  // Add service instance
  final VoiceBotService _voiceBotService = VoiceBotService();
  String? _currentRecordingPath;

  // Animation controllers
  late AnimationController _pulseAnimationController;
  late AnimationController _expandAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _flowAnimationController;

  // Animations
  late Animation<double> _expandAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize voice bot service
    _initVoiceBotService();

    // Bubble floating animation (subtle up and down movement)
    _floatingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Pulse animation for the bubble when idle
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Expand animation for when the button is tapped
    _expandAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Wave animation for the bubble when recording
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _flowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Duration of one full rotation
    )..repeat(); // Repeat indefinitely

    // Configure animations
    _expandAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5, // How much larger the bubble gets when expanded
    ).animate(CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeOut,
    ));
  }

  // Initialize the voice bot service
  Future<void> _initVoiceBotService() async {
    try {
      await _voiceBotService.init();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize voice service: $e');
    }
  }

  // Show error message as a snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Start recording
  Future<void> _startRecording() async {
    try {
      final path = await _voiceBotService.startRecording();
      setState(() {
        _currentRecordingPath = path;
        _isRecording = true;
        _isExpanded = true;
        _recognizedText = 'Listening...';
      });
      _expandAnimationController.forward();
      _pulseAnimationController.stop();
      _flowAnimationController.repeat();
    } catch (e) {
      _showErrorSnackBar('Failed to start recording: $e');
    }
  }

  // Stop recording and process the audio
  Future<void> _stopRecording() async {
    try {
      final path = await _voiceBotService.stopRecording();

      if (path != null) {
        setState(() {
          _isRecording = false;
          _isProcessing = true;
          _recognizedText = 'Processing...';
        });

        _expandAnimationController.reverse();
        _flowAnimationController.stop();
        _pulseAnimationController.repeat(reverse: true);

        // Process the recording
        await _processRecording(path);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to stop recording: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _isExpanded = false;
        _recognizedText = 'Tap the bubble to start recording';
      });
    }
  }

  // Process the recording and send to API
  Future<void> _processRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final result = await _voiceBotService.sendVoiceFile(file);

        if (result['success']) {
          setState(() {
            _recognizedText = result['data'];
            _isProcessing = false;
          });
        } else {
          _showErrorSnackBar('API Error: ${result['error']}');
          setState(() {
            _isProcessing = false;
            _recognizedText = 'Tap the bubble to start recording';
          });
        }
      } else {
        _showErrorSnackBar('Recording file not found');
        setState(() {
          _isProcessing = false;
          _recognizedText = 'Tap the bubble to start recording';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to process recording: $e');
      setState(() {
        _isProcessing = false;
        _recognizedText = 'Tap the bubble to start recording';
      });
    }
  }

  void _toggleRecording() {
    if (_isProcessing) return; // Don't allow toggling while processing

    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              // Colors.white,
              Color.fromRGBO(255, 255, 255, 0.702),
              Color.fromRGBO(255, 174, 235, 0.702),
              Color.fromRGBO(94, 159, 243, 1),
            ],
            stops: [0.3, 0.6, 1.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
              ),
              const SizedBox(height: 10),
              Text(
                'Nexi',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[
                        Color.fromRGBO(207, 202, 245, 1),
                        Color.fromRGBO(121, 119, 252, 1),
                        Color.fromRGBO(229, 168, 246, 1),
                      ],
                    ).createShader(Rect.fromLTWH(1.9, 1, 200.0, 170.0)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ask Nexi Anything',
                style: GoogleFonts.poppins(
                    fontSize: 20, color: const Color.fromRGBO(78, 78, 78, 1)),
              ),
              Expanded(
                child: Center(
                  child:
                      _recognizedText != 'Tap the bubble to start recording' &&
                              _recognizedText != 'Listening...' &&
                              _recognizedText != 'Processing...'
                          ? Container(
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _recognizedText,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _floatingAnimationController,
                      _pulseAnimationController,
                      _expandAnimationController,
                      _waveAnimationController,
                      _flowAnimationController,
                    ]),
                    builder: (context, child) {
                      final floatingOffset = math.sin(
                              _floatingAnimationController.value * math.pi) *
                          5;
                      final pulseScale =
                          1.0 + (_pulseAnimationController.value * 0.05);
                      final expandScale = _expandAnimation.value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isExpanded)
                            Container(
                              width: 120 * expandScale,
                              height: 150 * expandScale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white
                                        .withOpacity(_opacityAnimation.value),
                                    Colors.white.withOpacity(0),
                                  ],
                                  stops: const [0.1, 0.7],
                                ),
                              ),
                            ),
                          Transform.translate(
                            offset: Offset(0, floatingOffset),
                            child: Transform.scale(
                              scale: _isExpanded ? expandScale : pulseScale,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: BubblePainter(
                                    isRecording: _isRecording,
                                    flowPhase: _flowAnimationController.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _expandAnimationController.dispose();
    _floatingAnimationController.dispose();
    _waveAnimationController.dispose();
    _flowAnimationController.dispose();
    _voiceBotService.dispose(); // Clean up the voice service
    super.dispose();
  }
}

class BubblePainter extends CustomPainter {
  final bool isRecording;
  final double flowPhase;
  final List<Bubble> bubbles;

  BubblePainter({
    required this.isRecording,
    required this.flowPhase,
  }) : bubbles = List.generate(
            0,
            (index) => Bubble(
                  size: math.Random().nextDouble() * 0.4 + 0.2,
                  position: Offset(
                    math.Random().nextDouble() * 1.5 - 0.25,
                    math.Random().nextDouble() * 1.5 - 0.25,
                  ),
                  opacity: math.Random().nextDouble() * 0.3 + 0.1,
                  speed: math.Random().nextDouble() * 0.02 + 0.01,
                ));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 6);
    final radius = size.width / 3;

    // Draw background glow effect
    // if (isRecording) {
    //   final glowPaint = Paint()
    //     ..color = Color.fromRGBO(138, 101, 255, 0.2)
    //     ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30);

    //   canvas.drawCircle(center, radius * 1.5, glowPaint);
    // }

    // Draw main bubble with more sophisticated gradient
    _drawMainBubble(canvas, size, center, radius);

    // Draw multiple small bubbles inside
    _drawSmallBubbles(canvas, size, center, radius);

    // Draw highlights and reflections
    _drawHighlights(canvas, center, radius);

    // Draw rim/edge with subtle border
    _drawRim(canvas, center, radius);

    // Add recording indicator if recording
    // if (isRecording) {
    // _drawRecordingIndicator(canvas, center, radius, size);
    // }
  }

  void _drawMainBubble(Canvas canvas, Size size, Offset center, double radius) {
    // Create a more sophisticated gradient for the main bubble
    final Gradient gradient = RadialGradient(
      center: Alignment(0.9, -0.1),
      radius: 1.2,
      colors: [
        Color.fromRGBO(180, 150, 255, 0.7), // Light purple
        Color.fromRGBO(18, 101, 255, 0.7), // Mid purple
        Color.fromRGBO(96, 169, 246, 0.7), // Blue
        Color.fromRGBO(70, 130, 240, 0.6), // Darker blue
      ],
      stops: [0.0, 0.3, 0.6, 1.0],
    );

    // Create a more interesting bubble shape
    final path = Path();

    // Calculate rotation and scale based on flowPhase
    final rotationAngle = flowPhase * 2 * math.pi;
    final scaleVariation = 0.05 * math.sin(flowPhase * 4 * math.pi);

    // Create a slightly deformed circle using bezier curves
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double nextAngle = (i + 1) * math.pi / 4;

      double radiusMod =
          radius * (1.0 + 0.05 * math.sin(angle * 3 + flowPhase * math.pi * 2));
      double nextRadiusMod = radius *
          (1.0 + 0.05 * math.sin(nextAngle * 3 + flowPhase * math.pi * 2));

      Offset point = Offset(center.dx + math.cos(angle) * radiusMod * 1.45,
          center.dy + math.sin(angle) * radiusMod * 1.5);

      Offset nextPoint = Offset(
          center.dx + math.cos(nextAngle) * nextRadiusMod * 1.45,
          center.dy + math.sin(nextAngle) * nextRadiusMod * 1.5);

      Offset controlPoint1 = Offset(
          center.dx + math.cos(angle + math.pi / 8) * radiusMod * 1.6,
          center.dy + math.sin(angle + math.pi / 8) * radiusMod * 1.7);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      }

      path.quadraticBezierTo(
          controlPoint1.dx, controlPoint1.dy, nextPoint.dx, nextPoint.dy);
    }

    path.close();

    // Draw with rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.scale(1.0 + scaleVariation, 1.0 - scaleVariation);
    canvas.translate(-center.dx, -center.dy);

    // Create and apply shader
    final Rect rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );

    final Paint bubblePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(rect);

    canvas.drawPath(path, bubblePaint);
    canvas.restore();
  }

  void _drawSmallBubbles(
      Canvas canvas, Size size, Offset center, double radius) {
    for (var bubble in bubbles) {
      final position = Offset(
          center.dx + (bubble.position.dx - 0.5) * radius * 2,
          center.dy + (bubble.position.dy - 0.5) * radius * 2);

      // Calculate animation for each bubble
      final offset =
          math.sin(flowPhase * math.pi * 2 + bubble.position.dx * 10) *
              radius *
              0.1;
      final animatedPosition = Offset(position.dx + offset,
          position.dy - bubble.speed * radius * flowPhase * 10 % (radius * 2));

      final bubblePaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, bubble.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          animatedPosition, radius * bubble.size * 0.3, bubblePaint);
    }
  }

  void _drawHighlights(Canvas canvas, Offset center, double radius) {
    // Draw upper-left highlight (simulates light reflection)
    final highlightPaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.4)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    canvas.drawPath(highlightPath, highlightPaint);

    // Add smaller secondary highlight
    final secondaryHighlightPaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.3)
      ..style = PaintingStyle.fill;
  }

  void _drawRim(Canvas canvas, Offset center, double radius) {
    // Draw subtle rim/edge
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(255, 255, 255, 0.3)
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 1.47, rimPaint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) =>
      oldDelegate.isRecording != isRecording ||
      oldDelegate.flowPhase != flowPhase;
}

class Bubble {
  final double size;
  final Offset position;
  final double opacity;
  final double speed;

  Bubble({
    required this.size,
    required this.position,
    required this.opacity,
    required this.speed,
  });
}

// class WavePainter extends CustomPainter {
//   final bool isRecording;
//   final double flowPhase;
//   final int numWaves;

//   WavePainter({
//     required this.isRecording,
//     required this.flowPhase,
//     this.numWaves = 3,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 4);
//     final radius = size.width / 3;

//     // Draw main bubble with gradient
//     _drawMainBubble(canvas, size, center, radius);

//     // Draw waves inside
//     _drawWaves(canvas, size, center, radius);

//     // Draw highlights and reflections
//     _drawHighlights(canvas, center, radius);

//     // Draw rim/edge with subtle border
//     _drawRim(canvas, center, radius);
//   }

//   void _drawMainBubble(Canvas canvas, Size size, Offset center, double radius) {
//     // Create a smooth gradient for the main bubble
//     final Gradient gradient = RadialGradient(
//       center: Alignment(0.3, -0.3),
//       radius: 1.2,
//       colors: [
//         Color.fromRGBO(200, 170, 255, 0.7), // Light purple
//         Color.fromRGBO(138, 101, 255, 0.7), // Mid purple
//         Color.fromRGBO(96, 169, 246, 0.7), // Blue
//         Color.fromRGBO(70, 130, 240, 0.6), // Darker blue
//       ],
//       stops: [0.0, 0.3, 0.6, 1.0],
//     );

//     // Calculate rotation and scale based on flowPhase
//     final rotationAngle = flowPhase * math.pi / 6; // Subtle rotation
//     final scaleVariation = 0.02 * math.sin(flowPhase * 3 * math.pi);

//     // Draw with rotation
//     canvas.save();
//     canvas.translate(center.dx, center.dy);
//     canvas.rotate(rotationAngle);
//     canvas.scale(1.0 + scaleVariation, 1.0 - scaleVariation);
//     canvas.translate(-center.dx, -center.dy);

//     // Create and apply shader
//     final Rect rect = Rect.fromCenter(
//       center: center,
//       width: size.width,
//       height: size.height,
//     );

//     final Paint bubblePaint = Paint()
//       ..style = PaintingStyle.fill
//       ..shader = gradient.createShader(rect);

//     canvas.drawCircle(center, radius * 1.45, bubblePaint);
//     canvas.restore();
//   }

//   void _drawWaves(Canvas canvas, Size size, Offset center, double radius) {
//     canvas.save();

//     // Create clipping to keep waves inside the circle
//     final clipPath = Path()
//       ..addOval(Rect.fromCircle(center: center, radius: radius * 1.4));
//     canvas.clipPath(clipPath);

//     // Draw multiple waves with different phases and colors
//     for (int i = 0; i < numWaves; i++) {
//       final wavePhase = (flowPhase + i * 0.25) % 1.0;
//       final opacity = 0.5 - (i * 0.1);
//       final amplitude = radius * 0.15 * (1 - i * .2);

//       final period = radius * 0.30;

//       // Different colors for each wave
//       final Color waveColor = i == 0
//           ? Color.fromRGBO(255, 255, 255, opacity)
//           : i == 1
//               ? Color.fromRGBO(160, 220, 255, opacity)
//               : Color.fromRGBO(180, 180, 255, opacity);

//       _drawSingleWave(canvas, size, center, radius, wavePhase, amplitude,
//           period, waveColor);

//       _drawSecondWave(canvas, size, center, radius, wavePhase, amplitude,
//           period, waveColor);
//     }

//     canvas.restore();
//   }

//   void _drawSingleWave(Canvas canvas, Size size, Offset center, double radius,
//       double phase, double amplitude, double period, Color color) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path();

//     // Start at the left side
//     path.moveTo(center.dx - radius * 1.4, center.dy);

//     // Generate the wave path
//     for (double x = -radius * 1.4; x <= radius * 1.4; x += 1) {
//       // Calculate wave y-position based on sine function
//       final waveY =
//           center.dy + amplitude * math.sin((x / period) + phase * math.pi * 8);

//       // Add point to path
//       path.lineTo(center.dx + x, waveY);
//     }

//     // Complete the path by drawing to bottom and back to start
//     path.lineTo(center.dx + radius * 1.4, center.dy + radius * 1.4);
//     path.lineTo(center.dx - radius * 1.4, center.dy + radius * 1.4);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   void _drawSecondWave(Canvas canvas, Size size, Offset center, double radius,
//       double phase, double amplitude, double period, Color color) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path();

//     // Start at the left side
//     path.moveTo(center.dx - radius * 1.8, center.dy);

//     // Generate the wave path
//     for (double x = -radius * 1.8; x <= radius * 1.8; x += 2) {
//       // Calculate wave y-position based on sine function
//       final waveY =
//           center.dy + amplitude * math.sin((x / period) + phase * math.pi * 8);

//       // Add point to path
//       path.lineTo(center.dx + x, waveY);
//     }

//     // Complete the path by drawing to bottom and back to start
//     path.lineTo(center.dx + radius * 2.4, center.dy + radius * 2.4);
//     path.lineTo(center.dx - radius * 2.4, center.dy + radius * 2.4);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   void _drawHighlights(Canvas canvas, Offset center, double radius) {
//     // Draw upper-left highlight (simulates light reflection)
//     final highlightPaint = Paint()
//       ..color = Color.fromRGBO(255, 255, 255, 0.4)
//       ..style = PaintingStyle.fill;

//     final highlightPath = Path();
//     highlightPath.addOval(
//       Rect.fromCenter(
//         center: Offset(center.dx - radius * 0.4, center.dy - radius * 0.4),
//         width: radius * 0.8,
//         height: radius * 0.7,
//       ),
//     );
//     canvas.drawPath(highlightPath, highlightPaint);

//     // Add smaller secondary highlight
//     final secondaryHighlightPaint = Paint()
//       ..color = Color.fromRGBO(255, 255, 255, 0.3)
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(
//         Offset(center.dx + radius * 0.5, center.dy - radius * 0.6),
//         radius * 0.2,
//         secondaryHighlightPaint);
//   }

//   void _drawRim(Canvas canvas, Offset center, double radius) {
//     // Draw subtle rim/edge
//     final rimPaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..color = Color.fromRGBO(255, 255, 255, 0.3)
//       ..strokeWidth = 1.5;

//     canvas.drawCircle(center, radius * 1.45, rimPaint);
//   }

//   @override
//   bool shouldRepaint(WavePainter oldDelegate) =>
//       oldDelegate.isRecording != isRecording ||
//       oldDelegate.flowPhase != flowPhase;
// }
