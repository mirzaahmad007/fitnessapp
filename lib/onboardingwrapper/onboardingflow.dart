import 'package:fitnessapp/userscreens/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/homescreen/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'planesce.dart';
import 'sendatorypage.dart';
import 'weeklypage.dart';
import 'weightpage.dart';
import 'yogascreen.dart';
import 'agepage.dart';
import 'bodyshape.dart';
import 'expericebody.dart';
import 'focusareapage.dart';
import 'gender.dart';
import 'heightpage.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();

  /// ✅ Call when onboarding is done
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingCompleted", true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FitnessHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1
          GenderSelectionPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          // Step 2
          FocusAreaPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          YogaPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          BodyPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          ExperiencePage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          SedentaryLifestylePage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          PlankEndurancePage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          Age3DPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          HeightSelectionPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          WeightSelectionPage(
            onNext: () => _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),

          /// ✅ Last Step -> Go to Home
          WeeklyYogaPlanPage(
            onNext: _finishOnboarding,
            onBack: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
