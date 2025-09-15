import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/exercise.dart'; // Assuming this is the correct import path

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  final int _workoutSeconds = 60; // Fixed workout time: 1 minute
  final int _breakSeconds = 20; // Fixed break time: 20 seconds
  bool _isWorkoutRunning = false;
  bool _isBreakRunning = false;
  bool _isPaused = false; // Added to track paused state
  int _currentDuration = 60; // Tracks current timer duration
  final CountDownController _controller = CountDownController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
    // Initialize current duration
    _currentDuration = _workoutSeconds;
    // Preload audio to reduce latency
    _preloadSounds();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Preload sounds to reduce latency
  Future<void> _preloadSounds() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/countdown.mp3')); // Fixed typo in sound file name
      await _audioPlayer.setSource(AssetSource('sounds/breaks.mp3'));
      debugPrint('Sounds preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading sounds: $e');
    }
  }

  // Determine avatar and timer circle size based on screen width
  double _getAvatarRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 80.0;
    if (width > 600) return 70.0;
    return 60.0;
  }

  double _getTimerRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 70.0;
    if (width > 600) return 60.0;
    return 50.0;
  }

  // Play sound based on phase
  Future<void> _playSound(bool isWorkout) async {
    try {
      await _audioPlayer.stop(); // Stop any ongoing sound
      final soundPath = isWorkout ? 'sounds/countdown.mp3' : 'sounds/breaks.mp3';
      await _audioPlayer.setSource(AssetSource(soundPath));
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency); // Reduce playback delay
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Set sound to loop
      await _audioPlayer.play(AssetSource(soundPath));
      debugPrint('Playing sound: $soundPath');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Stop sound
  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
      debugPrint('Sound stopped');
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  // Start, pause, or resume the timer
  void _toggleTimer() {
    if (_isWorkoutRunning || _isBreakRunning) {
      _controller.pause();
      _stopSound();
      setState(() {
        _isWorkoutRunning = false;
        _isBreakRunning = false;
        _isPaused = true; // Mark as paused
      });
    } else {
      setState(() {
        if (_isPaused) {
          // Resume the timer
          if (_currentDuration == _breakSeconds) {
            _isBreakRunning = true;
            _playSound(false); // Resume break sound
          } else {
            _isWorkoutRunning = true;
            _playSound(true); // Resume workout sound
          }
          _controller.resume(); // Resume from paused time
        } else {
          // Start a new timer cycle
          if (_currentDuration == _breakSeconds) {
            _isBreakRunning = true;
            _playSound(false); // Play break sound
          } else {
            _isWorkoutRunning = true;
            _playSound(true); // Play workout sound
          }
          _controller.start(); // Start new countdown
        }
        _isPaused = false; // Reset paused state
      });
    }
  }

  // Handle timer completion
  void _onTimerComplete() {
    if (_isWorkoutRunning) {
      Vibration.vibrate(duration: 500); // Haptic feedback
      _stopSound();
      _playSound(false); // Play break sound
      setState(() {
        _isWorkoutRunning = false;
        _isBreakRunning = true;
        _currentDuration = _breakSeconds;
        _controller.restart(duration: _breakSeconds);
        _controller.start(); // Start break countdown
        _isPaused = false; // Reset paused state
      });
    } else if (_isBreakRunning) {
      Vibration.vibrate(duration: 500);
      _stopSound();
      setState(() {
        _isBreakRunning = false;
        _currentDuration = _workoutSeconds;
        _controller.restart(duration: _workoutSeconds);
        _controller.pause(); // Pause after break completes
        _isPaused = false; // Reset paused state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.0,
            kToolbarHeight + 10.0,
            20.0,
            20.0,
          ),
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.exercise.gifUrl.isNotEmpty)
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()..scale(_isVisible ? 1.0 : 0.9),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: _getAvatarRadius(context),
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.exercise.gifUrl,
                              fit: BoxFit.cover,
                              width: _getAvatarRadius(context) * 2,
                              height: _getAvatarRadius(context) * 2,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24.0),
                Text(
                  widget.exercise.name,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.purple.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        Center(
                          child: Column(
                            children: [
                              CircularCountDownTimer(
                                duration: _currentDuration,
                                initialDuration: 0,
                                controller: _controller,
                                width: _getTimerRadius(context) * 2,
                                height: _getTimerRadius(context) * 2,
                                ringColor: Colors.grey.shade300, // simple ring color
                                fillColor: _isBreakRunning ? Colors.green.shade400 : Colors.orange.shade400, // solid fill color
                                backgroundColor: Colors.white, // solid background color
                                strokeWidth: 8.0,
                                strokeCap: StrokeCap.round,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                textFormat: CountdownTextFormat.MM_SS,
                                isReverse: true,
                                isReverseAnimation: true,
                                isTimerTextShown: true,
                                autoStart: false,
                                onComplete: _onTimerComplete,
                                timeFormatterFunction: (defaultFormatterFunction, duration) {
                                  if (_isWorkoutRunning || _isBreakRunning) {
                                    return defaultFormatterFunction(duration);
                                  } else {
                                    return defaultFormatterFunction(Duration(seconds: _currentDuration));
                                  }
                                },
                              ),
                              if (_isBreakRunning)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Breaktime',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: _toggleTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isBreakRunning ? Colors.green.shade700 : Colors.orange.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: Text(
                                  _isWorkoutRunning || _isBreakRunning ? 'Stop' : 'Start',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Instructions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12.0),
                if (widget.exercise.instructions != null && widget.exercise.instructions!.isNotEmpty)
                  ...List.generate(
                    widget.exercise.instructions!.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.purple.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.exercise.instructions![index],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.purple.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'No instructions available.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}