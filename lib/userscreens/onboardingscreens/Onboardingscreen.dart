import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../loginscreen.dart';
import 'loginscreen.dart'; // 👈 apni login screen import karo

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/ladyboy.png",
      "title": "Track Your Workouts",
      "desc": "Stay consistent and monitor every step of your fitness journey."
    },
    {
      "image": "assets/images/count.png",
      "title": "Stay Healthy Everyday",
      "desc": "Count your steps, burn calories, and keep your body active daily."
    },
    {
      "image": "assets/images/goals.png",
      "title": "Achieve Your Fitness Goals",
      "desc": "Set personal targets and celebrate every milestone you achieve."
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 📌 PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 80, left: 20, right: 20, bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade100, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80),   // 👈 upar ka curve
                        // 👈 upar ka curve
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 3,
                          offset: const Offset(5, 5),
                        ),
                      ],
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _pages[index]["image"]!,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _pages[index]["title"]!,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔘 Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                width: _currentIndex == index ? 30 : 12,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.teal : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 📌 Bottom Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _currentIndex == _pages.length - 1
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _goToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button → Last Page
                GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(_pages.length - 1); // 👈 last page par le jao
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("Skip"),
                  ),
                ),

                // Continue Button
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
