import 'dart:async';
import 'package:fitnessapp/services/sleep.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/sleep_service.dart';

class SleepTracker extends StatefulWidget {
  final double sleepGoal;

  const SleepTracker({
    super.key,
    this.sleepGoal = 8.0,
  });

  @override
  _SleepTrackerState createState() => _SleepTrackerState();
}

class _SleepTrackerState extends State<SleepTracker> {
  bool _isTracking = false;
  double _sleepHours = 0.0;
  late Timer _timer;
  double _motionThreshold = 1.0;
  double _motionAverage = 0.0;
  List<double> _accelerometerValues = <double>[0, 0, 0];

  final SleepService _sleepService = SleepService();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        if (_motionAverage < _motionThreshold) {
          setState(() {
            _sleepHours += 1 / 3600; // 1 second = 1/3600 hours
          });
        }
      }
    });

    accelerometerEvents.listen((event) {
      if (_isTracking) {
        setState(() {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          _motionAverage = _accelerometerValues
              .map((d) => d.abs())
              .reduce((a, b) => a + b) /
              3;
        });
      }
    });

    _loadTodayData(); // ✅ Auto load
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startSleep() {
    setState(() {
      _isTracking = true;
      _sleepHours = 0.0;
    });
    _showSnack("😴 Sleep tracking started!");
  }

  Future<void> _stopSleep() async {
    setState(() {
      _isTracking = false;
    });

    await _sleepService.saveSleepData(
      sleepHours: _sleepHours,
      sleepGoal: widget.sleepGoal,
      motionAverage: _motionAverage,
    );

    _showSnack("🛑 Sleep tracking stopped & saved!");
  }

  void _resetSleep() {
    setState(() {
      _isTracking = false;
      _sleepHours = 0.0;
      _motionAverage = 0.0;
    });
    _showSnack("🔄 Sleep data reset!");
  }

  Future<void> _loadTodayData() async {
    final data = await _sleepService.getSleepData();
    if (data != null) {
      setState(() {
        _sleepHours = (data["sleepHours"] as num).toDouble();
        _motionAverage = (data["motionAverage"] as num).toDouble();
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 16)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize = screenWidth * 0.05;
    final double cardPadding = screenWidth * 0.04;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("😴", style: TextStyle(fontSize: baseFontSize * 1.8)),
                    SizedBox(width: cardPadding * 0.5),
                    Text(
                      "Sleep Tracker",
                      style: GoogleFonts.poppins(
                        fontSize: baseFontSize * 1.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: cardPadding),
                CircularPercentIndicator(
                  radius: screenWidth * 0.2,
                  lineWidth: screenWidth * 0.04,
                  animation: true,
                  animationDuration: 800,
                  percent: (_sleepHours.clamp(0.0, widget.sleepGoal)) /
                      widget.sleepGoal,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${(_sleepHours / widget.sleepGoal * 100).toStringAsFixed(0)}%",
                        style: GoogleFonts.poppins(
                          fontSize: baseFontSize * 1.2,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Goal",
                        style: GoogleFonts.poppins(
                          fontSize: baseFontSize * 0.7,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  linearGradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.blueAccent],
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                SizedBox(height: cardPadding * 0.8),
                Text(
                  "Elapsed: ${_sleepHours.toStringAsFixed(1)}h / ${widget.sleepGoal}h\nMotion: ${_motionAverage.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontSize: baseFontSize * 0.85,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: cardPadding * 1.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton("Start", Colors.green, _startSleep,
                        enabled: !_isTracking),
                    _buildButton("Stop", Colors.red, _stopSleep,
                        enabled: _isTracking),
                    _buildButton("Reset", Colors.orange, _resetSleep),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed,
      {bool enabled = true}) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: color.withOpacity(0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
