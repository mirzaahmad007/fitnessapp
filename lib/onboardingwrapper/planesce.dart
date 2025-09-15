import 'package:flutter/material.dart';

import 'onboardingwrapper.dart';

class PlankEndurancePage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const PlankEndurancePage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<PlankEndurancePage> createState() => _PlankEndurancePageState();
}

class _PlankEndurancePageState extends State<PlankEndurancePage> {
  double sliderValue = 1; // 0 = <20s, 1 = 20s–60s, 2 = >60s
  final List<String> ranges = ["< 20s", "20s - 60s", "> 60s"];

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 7,
      totalSteps: 11,
      title: "How Long Can You Hold a\nPlank?",
      subtitle: "Show us your core endurance.",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Illustration placeholder
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 40),
            child: const Center(
              child: Image(image: AssetImage("assets/images/plank.png")),
            ),
          ),

          /// Slider
          Slider(

            value: sliderValue,
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: Colors.purple,
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() {
                sliderValue = value;
              });
            },
          ),

          /// Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(ranges.length, (index) {
              final isSelected = sliderValue.round() == index;
              return Text(
                ranges[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.purple : Colors.grey,
                ),
              );
            }),
          ),
        ],
      ),
      onNext: () {
        debugPrint("Plank endurance: ${ranges[sliderValue.round()]}");
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}
