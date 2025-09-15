import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'onboardingwrapper.dart';

class ExperiencePage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const ExperiencePage({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  int? selectedIndex;

  final List<Map<String, String>> levels = [
    {"title": "Beginner", "subtitle": "I'm new to yoga"},
    {"title": "Intermediate", "subtitle": "I practice yoga regularly"},
    {"title": "Expert", "subtitle": "I am experienced & living with yoga"},
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 5,
      totalSteps: 11,
      title: "Have You Experienced\nYoga Before?",
      subtitle: "Share your yoga background with us.",
      content: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? Colors.purple.withOpacity(0.05) : Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level["title"]!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.purple : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level["subtitle"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check, color: Colors.purple),
                ],
              ),
            ),
          );
        },
      ),
      onNext: () {
        // ✅ Call parent onNext after logging selection
        debugPrint("Selected Level: ${selectedIndex != null ? levels[selectedIndex!]['title'] : 'None'}");
        widget.onNext();
      },
      onBack: widget.onBack,
    );
  }
}