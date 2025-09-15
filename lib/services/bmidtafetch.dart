import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:animate_do/animate_do.dart';

class BMIGauge extends StatelessWidget {
  const BMIGauge({super.key});

  Future<Map<String, dynamic>?> _fetchLatestBMI() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user signed in');
      return null;
    }

    try {
      // Fetch userId from users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? userId;
      if (userDoc.exists) {
        userId = userDoc.data()?['userId']?.toString();
      }

      // Fall back to user.uid if userId is not found
      userId ??= user.uid;
      debugPrint('Using userId: $userId for BMI query');

      // Query bmi collection with userId
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bmi')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      debugPrint('No BMI data found for userId: $userId');
      return null;
    } catch (e) {
      debugPrint('Error fetching BMI: $e');
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
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading BMI data',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else if (FirebaseAuth.instance.currentUser == null) {
            return const Center(
              child: Text(
                'Please sign in to view BMI',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else if (snapshot.data == null) {
            return const Center(
              child: Text(
                'No BMI data available',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final double bmi = (data['bmi'] as num?)?.toDouble() ?? 0.0;
          final String category = data['category']?.toString() ?? 'Unknown';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
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
                      radiusFactor: 0.8,
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
                          color: Colors.redAccent,
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
                              fontSize: 12,
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
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 10,
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