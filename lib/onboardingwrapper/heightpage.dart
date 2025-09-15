import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'onboardingwrapper.dart';

class HeightSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const HeightSelectionPage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<HeightSelectionPage> createState() => _HeightSelectionPageState();
}

class _HeightSelectionPageState extends State<HeightSelectionPage> {
  bool useCm = true; // toggle between cm & ft

  int heightCm = 170;
  int heightFt = 5;
  int heightInch = 6;

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 9,
      totalSteps: 11,
      title: "What’s Your Height?",
      subtitle: "Select your height to personalize your plan.",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Toggle between cm and feet
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: const Text("cm"),
                  selected: useCm,
                  onSelected: (val) => setState(() => useCm = true),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: useCm ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("ft"),
                  selected: !useCm,
                  onSelected: (val) => setState(() => useCm = false),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: !useCm ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Height Picker
          if (useCm)
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  NumberPicker(
                    value: heightCm,
                    minValue: 50,
                    maxValue: 250,
                    step: 1,
                    axis: Axis.vertical,
                    itemCount: 5,
                    selectedTextStyle: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    textMapper: (number) => "$number cm",
                    onChanged: (value) => setState(() => heightCm = value),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.purple.withOpacity(0.3), width: 2),
                        bottom: BorderSide(
                            color: Colors.purple.withOpacity(0.3), width: 2),
                      ),
                    ),
                  ),
                  // gradient fade
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
            )
          else
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Feet Picker
                  Expanded(
                    child: NumberPicker(
                      value: heightFt,
                      minValue: 3,
                      maxValue: 8,
                      step: 1,
                      axis: Axis.vertical,
                      itemCount: 5,
                      selectedTextStyle: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      textMapper: (number) => "$number ft",
                      onChanged: (value) => setState(() => heightFt = value),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.purple.withOpacity(0.3), width: 2),
                          bottom: BorderSide(
                              color: Colors.purple.withOpacity(0.3), width: 2),
                        ),
                      ),
                    ),
                  ),

                  // Inches Picker
                  Expanded(
                    child: NumberPicker(
                      value: heightInch,
                      minValue: 0,
                      maxValue: 11,
                      step: 1,
                      axis: Axis.vertical,
                      itemCount: 5,
                      selectedTextStyle: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      textMapper: (number) => "$number in",
                      onChanged: (value) => setState(() => heightInch = value),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.purple.withOpacity(0.3), width: 2),
                          bottom: BorderSide(
                              color: Colors.purple.withOpacity(0.3), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      onNext: () {
        if (useCm) {
          debugPrint("Height: $heightCm cm");
        } else {
          debugPrint("Height: $heightFt ft $heightInch in");
        }
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}
