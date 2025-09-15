import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'onboardingwrapper.dart';

class WeightSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const WeightSelectionPage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  bool useKg = true;

  int weightKg = 70;
  int weightLbs = 154;

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 10,
      totalSteps: 11,
      title: "What’s Your Weight?",
      subtitle: "This helps us create a personalized plan for you.",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Toggle between kg and lbs
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
                  label: const Text("kg"),
                  selected: useKg,
                  onSelected: (val) => setState(() => useKg = true),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: useKg ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("lbs"),
                  selected: !useKg,
                  onSelected: (val) => setState(() => useKg = false),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: !useKg ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Number Picker (Wheel Style)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                NumberPicker(
                  value: useKg ? weightKg : weightLbs,
                  minValue: useKg ? 30 : 66, // 30 kg ~ 66 lbs
                  maxValue: useKg ? 200 : 440, // 200 kg ~ 440 lbs
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
                  textMapper: (number) =>
                  "$number ${useKg ? "kg" : "lbs"}",
                  onChanged: (value) => setState(() {
                    if (useKg) {
                      weightKg = value;
                      weightLbs = (value * 2.205).round();
                    } else {
                      weightLbs = value;
                      weightKg = (value / 2.205).round();
                    }
                  }),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.purple.withOpacity(0.3), width: 2),
                      bottom: BorderSide(
                          color: Colors.purple.withOpacity(0.3), width: 2),
                    ),
                  ),
                ),

                // gradient fade top-bottom
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
          ),
        ],
      ),
      onNext: () {
        if (useKg) {
          debugPrint("Weight: $weightKg kg");
        } else {
          debugPrint("Weight: $weightLbs lbs");
        }
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}
