import 'package:flutter/material.dart';
import 'dart:async';

import '../userscreens/Homescreen.dart';

class YogaPlanLoadingPage extends StatefulWidget {
  const YogaPlanLoadingPage({super.key});

  @override
  State<YogaPlanLoadingPage> createState() => _YogaPlanLoadingPageState();
}

class _YogaPlanLoadingPageState extends State<YogaPlanLoadingPage>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;
  Timer? timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // pulsating text animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.7,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // simulate progress
    timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (progress >= 1.0) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  FitnessHomePage()),
          );
        });
      } else {
        setState(() {
          progress += 0.02;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFB993D6),
              Color(0xFF8CA6DB),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular progress with yoga icon
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.self_improvement, // yoga icon
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Pulsating text
              ScaleTransition(
                scale: _pulseController,
                child: const Text(
                  "Creating Your Yoga Plan...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please wait a moment",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Example HomePage
