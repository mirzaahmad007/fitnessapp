import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'onboardingwrapper.dart';

class Age3DPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const Age3DPage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<Age3DPage> createState() => _Age3DPageState();
}

class _Age3DPageState extends State<Age3DPage> {
  int age = 25;

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 8,
      totalSteps: 11,
      title: "How Old Are You?",
      subtitle: "This helps us personalize your plan.",
      content: Stack(
        alignment: Alignment.center,
        children: [
          // Number Picker (3D wheel style)
          NumberPicker(
            value: age,
            minValue: 0,
            maxValue: 100,
            step: 1,
            axis: Axis.vertical,
            itemCount: 5, // visible items (for wheel feel)
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
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.purple.withOpacity(0.3), width: 2),
                bottom:
                BorderSide(color: Colors.purple.withOpacity(0.3), width: 2),
              ),
            ),
            onChanged: (value) => setState(() => age = value),
            textMapper: (number) => "$number years",
          ),

          // Gradient Fade (Top & Bottom for 3D illusion)
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
        debugPrint("Selected Age: $age years");
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}
