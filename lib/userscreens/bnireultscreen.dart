import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:animate_do/animate_do.dart';

class BMIGauge extends StatelessWidget {
  const BMIGauge({super.key});

  Future<Map<String, dynamic>?> _fetchLatestBMI() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // --- Try query with orderBy (needs composite index) ---
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bmi')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint("✅ BMI Data fetched with index: ${querySnapshot.docs.first.data()}");
        return querySnapshot.docs.first.data();
      } else {
        // --- fallback simple query (in case index not created) ---
        final fallbackSnapshot = await FirebaseFirestore.instance
            .collection('bmi')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (fallbackSnapshot.docs.isNotEmpty) {
          debugPrint("⚠️ Fallback BMI Data: ${fallbackSnapshot.docs.first.data()}");
          return fallbackSnapshot.docs.first.data();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching BMI: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchLatestBMI(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                'No BMI data',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final double bmi = (data['bmi'] as num).toDouble(); // safe cast
          final String category = data['category'] ?? 'Unknown';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white70, Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SfRadialGauge(
                  enableLoadingAnimation: true,
                  animationDuration: 1000,
                  axes: [
                    RadialAxis(
                      minimum: 10,
                      maximum: 40,
                      radiusFactor: 0.9,
                      showLabels: false,
                      showTicks: false,
                      ranges: [
                        GaugeRange(
                          startValue: 10,
                          endValue: 18.5,
                          color: Colors.orangeAccent,
                        ),
                        GaugeRange(
                          startValue: 18.5,
                          endValue: 24.9,
                          color: Colors.greenAccent,
                        ),
                        GaugeRange(
                          startValue: 24.9,
                          endValue: 29.9,
                          color: Colors.redAccent,
                        ),
                        GaugeRange(
                          startValue: 29.9,
                          endValue: 40,
                          color: Colors.red,
                        ),
                      ],
                      pointers: [
                        NeedlePointer(
                          value: bmi,
                          enableAnimation: true,
                          animationDuration: 1000,
                        ),
                      ],
                      annotations: [
                        GaugeAnnotation(
                          widget: Text(
                            bmi.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: category == 'Normal'
                      ? Colors.greenAccent
                      : category == 'Underweight'
                      ? Colors.orangeAccent
                      : Colors.redAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
