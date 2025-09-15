import 'package:flutter/material.dart';

class OnboardingWrapper extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback? onBack; // ✅ Added

  const OnboardingWrapper({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onNext,
    this.onBack, // ✅ Added
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Back + Progress
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      borderRadius: BorderRadius.circular(20),
                      value: step / totalSteps,
                      backgroundColor: Colors.grey[300],
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$step / $totalSteps",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Titles
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),

              // Dynamic content
              Expanded(child: content),

              // Bottom navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Continue",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
