import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'onboardingwrapper.dart';

class BodyPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  BodyPage({required this.onNext, this.onBack});

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  double sliderValue = 0.0;
  final List<String> bodyShapes = [
    "Slim",
    "Lean",
    "Average",
    "Athletic",
    "Muscular",
    "Stocky",
  ];
  final Map<int, String> imageAssets = {
    0: "assets/images/slim.png",
    1: "assets/images/lean.png",
    2: "assets/images/average.png",
    3: "assets/images/athletic.png",
    4: "assets/images/muscular.png",
    5: "assets/images/stocky.png",
  };

  @override
  Widget build(BuildContext context) {
    final selectedIndex = sliderValue.round().clamp(0, 5);
    final imagePath = imageAssets[selectedIndex] ?? imageAssets[0]!;

    return OnboardingWrapper(
      step: 4,
      totalSteps: 11,
      title: "Select Your Body Shape?",
      subtitle: "Choose your body type to personalize",
      onNext: () {
        if (sliderValue > 0.0) {
          widget.onNext();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a body shape')),
          );
        }
      },
      onBack: widget.onBack,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              imagePath,
              key: ValueKey<int>(selectedIndex),
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Image not loaded')),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Slider with labels below
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10.0, // Increased track thickness
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12.0, // Increased thumb radius
                    pressedElevation: 8.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20.0, // Larger overlay for tap area
                  ),
                ),
                child: Slider(
                  value: sliderValue,
                  min: 0.0,
                  max: 5.0,
                  divisions: 5,
                  label: bodyShapes[selectedIndex],
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey[300],
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      sliderValue = value.roundToDouble().clamp(0.0, 5.0);
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: bodyShapes.map((shape) {
                  final index = bodyShapes.indexOf(shape);
                  return Text(
                    shape,
                    style: TextStyle(
                      fontSize: 14,
                      color: sliderValue.round() == index ? Colors.purple : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}