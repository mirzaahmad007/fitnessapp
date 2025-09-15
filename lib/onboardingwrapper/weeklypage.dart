import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'creatplanpage.dart';
import 'onboardingwrapper.dart';

class WeeklyYogaPlanPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const WeeklyYogaPlanPage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<WeeklyYogaPlanPage> createState() => _WeeklyYogaPlanPageState();
}

class _WeeklyYogaPlanPageState extends State<WeeklyYogaPlanPage> {
  int daysPerWeek = 3;

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 11,
      totalSteps: 11,
      title: "Set Your Weekly Yoga Plan",
      subtitle: "Choose how many days you want to practice yoga per week.",
      content: Stack(
        alignment: Alignment.center,
        children: [
          // Number Picker
          NumberPicker(
            value: daysPerWeek,
            minValue: 1,
            maxValue: 7,
            axis: Axis.vertical,
            itemCount: 5,
            haptics: true,
            selectedTextStyle: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
            textMapper: (value) => "$value ${value == 1 ? "day" : "days"}",
            onChanged: (value) => setState(() => daysPerWeek = value),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.purple.withOpacity(0.3), width: 2),
                bottom: BorderSide(color: Colors.purple.withOpacity(0.3), width: 2),
              ),
            ),
          ),

          // Gradient fade (3D effect)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.0),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
      onNext: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const YogaPlanLoadingPage()),
        );
      },
      onBack: widget.onBack,
    );
  }
}
