import 'package:flutter/material.dart';

import 'onboardingwrapper.dart';

class SedentaryLifestylePage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const SedentaryLifestylePage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<SedentaryLifestylePage> createState() => _SedentaryLifestylePageState();
}

class _SedentaryLifestylePageState extends State<SedentaryLifestylePage> {
  int? selectedIndex; // 0 = No, 1 = Yes

  final List<String> options = ["No", "Yes"];

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 6,
      totalSteps: 11,
      title: "Do You Live a Sedentary\nLifestyle?",
      subtitle: "Tell us about your daily routine.",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Illustration placeholder (replace with Image.asset if you have asset)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Image(image: AssetImage("assets/images/sleep.png")),
            ),
          ),

          /// Yes / No buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(options.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  width: 120,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      onNext: () {
        debugPrint(
          "Sedentary Lifestyle: ${selectedIndex != null ? options[selectedIndex!] : 'None'}",
        );
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}
