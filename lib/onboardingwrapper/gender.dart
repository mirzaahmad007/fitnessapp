import 'package:flutter/material.dart';
import 'onboardingwrapper.dart';

class GenderSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  GenderSelectionPage({required this.onNext});

  @override
  _GenderSelectionPageState createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  PageController _controller = PageController(viewportFraction: 0.65);
  int selectedIndex = 0;

  final List<Map<String, String>> genders = [
    {"label": "Man", "asset": "assets/images/boy.png"},
    {"label": "Woman", "asset": "assets/images/girl.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 1,
      totalSteps: 11,
      title: "Select Your Gender",
      subtitle: "Let's start by understanding you.",
      onNext: widget.onNext,
      content: SizedBox(
        height: 400,
        child: PageView.builder(
          controller: _controller,
          itemCount: genders.length,
          onPageChanged: (index) {
            setState(() => selectedIndex = index);
          },
          itemBuilder: (context, index) {
            final gender = genders[index];
            bool isSelected = selectedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: isSelected ? 0 : 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // ✅ Purple circle background + decoration only if selected
                      if (isSelected)
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Positioned(top: 20, left: 20, child: _smallCircle()),
                              Positioned(top: 40, right: 10, child: _smallCircle()),
                              Positioned(bottom: 30, right: 30, child: _smallCircle()),
                              Positioned(bottom: 20, left: 40, child: _smallCircle()),
                            ],
                          ),
                        ),

                      // ✅ Character Image (zooms when selected)
                      AnimatedScale(
                        scale: isSelected ? 1.2 : 0.9,
                        duration: const Duration(milliseconds: 400),
                        child: Image.asset(
                          gender["asset"]!,
                          height: isSelected ? 330 : 250,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gender["label"]!,
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.purple : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _smallCircle() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.purple,
        shape: BoxShape.circle,
      ),
    );
  }
}
