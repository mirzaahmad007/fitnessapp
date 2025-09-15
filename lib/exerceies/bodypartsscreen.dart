import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'exercise_list_screen.dart';
import 'exerciselist.dart';

class Bodypartsscreen extends StatefulWidget {
  const Bodypartsscreen({super.key});

  @override
  State<Bodypartsscreen> createState() => _BodypartsscreenState();
}

class _BodypartsscreenState extends State<Bodypartsscreen> {
  final List<String> bodyParts = [
    'Back',
    'Cardio',
    'Chest',
    'Lower Arms',
    'Lower Legs',
    'Neck',
    'Shoulders',
    'Upper Arms',
    'Upper Legs',
    'Waist'
  ];

  /// Map body parts to image paths (replace with your own image assets)
  final Map<String, String> bodyPartImages = {
    'Back': 'assets/images/back1.png',
    'Cardio': 'assets/images/cardio1.png',
    'Chest': 'assets/images/chest1.png',
    'Lower Arms': 'assets/images/lower_arms.png',
    'Lower Legs': 'assets/images/lower_legs.png',
    'Neck': 'assets/images/neck.png',
    'Shoulders': 'assets/images/shoulders.png',
    'Upper Arms': 'assets/images/upper_arms.png',
    'Upper Legs': 'assets/images/upper_legs.png',
    'Waist': 'assets/images/waist.png',
  };

  final Map<int, bool> _isTapped = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < bodyParts.length; i++) {
      _isTapped[i] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Body Parts',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.0,
            ),
            itemCount: bodyParts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isTapped[index] = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isTapped[index] = false;
                  });
                  Vibration.vibrate(duration: 50);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseListScreen(
                        bodyPart: bodyParts[index]
                            .toLowerCase()
                            .replaceAll(' ', '%20'),
                      ),
                    ),
                  );
                },
                onTapCancel: () {
                  setState(() {
                    _isTapped[index] = false;
                  });
                },
                child: AnimatedScale(
                  scale: _isTapped[index]! ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Material(
                    elevation: 6, // ✅ Material elevation
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black.withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ Replace Icon with Image
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: Image.asset(
                              bodyPartImages[bodyParts[index]] ??
                                  'assets/images/default.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            bodyParts[index],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
