import 'package:flutter/material.dart';
import 'onboardingwrapper.dart';

class YogaPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const YogaPage({Key? key, required this.onNext, this.onBack}) : super(key: key);

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  List<String> selectedGoals = [];

  final List<Map<String, dynamic>> goals = [
    {"icon": "🏋️", "label": "Weight Loss"},
    {"icon": "😴", "label": "Better Sleep Quality"},
    {"icon": "🧘", "label": "Body Relaxation"},
    {"icon": "🍏", "label": "Improve Health"},
    {"icon": "🪷", "label": "Relieve Stress"},
    {"icon": "🦶", "label": "Posture Correction"},
  ];

  void toggleSelection(String label) {
    setState(() {
      if (selectedGoals.contains(label)) {
        selectedGoals.remove(label);
      } else {
        selectedGoals.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 3,
      totalSteps: 11,
      title: "What's Your Yoga Goal?",
      subtitle: "Tell us what you aim to achieve with Asana.",
      onNext: () {
        print("✅ Selected Goals: $selectedGoals");
        widget.onNext();
      },
      onBack: widget.onBack,
      content: Column(
        children: goals.map((goal) {
          final isSelected = selectedGoals.contains(goal["label"]);

          return GestureDetector(
            onTap: () => toggleSelection(goal["label"]),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.grey.shade300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(goal["icon"], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal["label"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.purple : Colors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.purple, size: 22),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
