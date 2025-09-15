import 'package:fitnessapp/homescreen/weeklydata.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({super.key});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> weeklyData = [];

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime startDate = now.subtract(const Duration(days: 6)); // Last 7 days

      // Fetch steps data
      final stepsSnap = await _firestore
          .collection('steps')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(startDate))
          .get();

      // Fetch sleep data
      final sleepSnap = await _firestore
          .collection('sleep_data')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(startDate))
          .get();

      // Fetch user data for todayintakeml
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final todayIntakeMl = userDoc.data()?['todayintakeml'] ?? 0;

      // Aggregate data by day
      final Map<String, Map<String, dynamic>> dailyData = {};
      for (final doc in stepsSnap.docs) {
        final dateStr = doc['date'];
        final date = DateTime.tryParse(dateStr) ?? DateTime(1970);
        final dayKey = DateFormat('yyyy-MM-dd').format(date);
        dailyData[dayKey] ??= {'steps': 0, 'calories': 0, 'workouts': 0, 'sleep': 0, 'water': 0, 'day': DateFormat('EEE').format(date)};
        dailyData[dayKey]!['steps'] = (dailyData[dayKey]!['steps'] as num) + (doc['steps'] ?? 0);
        dailyData[dayKey]!['calories'] = (dailyData[dayKey]!['calories'] as num) + (doc['calories'] ?? 0);
        dailyData[dayKey]!['workouts'] = (dailyData[dayKey]!['workouts'] as num) + (doc['workouts'] ?? 0); // Assume workouts if present
      }
      for (final doc in sleepSnap.docs) {
        final dateStr = doc['date'];
        final date = DateTime.tryParse(dateStr) ?? DateTime(1970);
        final dayKey = DateFormat('yyyy-MM-dd').format(date);
        dailyData[dayKey] ??= {'steps': 0, 'calories': 0, 'workouts': 0, 'sleep': 0, 'water': 0, 'day': DateFormat('EEE').format(date)};
        dailyData[dayKey]!['sleep'] = (dailyData[dayKey]!['sleep'] as num) + (doc['sleep'] ?? 0);
      }
      // Add todayintakeml for the current day
      final todayKey = DateFormat('yyyy-MM-dd').format(now);
      dailyData[todayKey] ??= {'steps': 0, 'calories': 0, 'workouts': 0, 'sleep': 0, 'water': 0, 'day': DateFormat('EEE').format(now)};
      dailyData[todayKey]!['water'] = (dailyData[todayKey]!['water'] as num) + (todayIntakeMl as num);

      // Fill in missing days
      final weeklyList = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayKey = DateFormat('yyyy-MM-dd').format(date);
        final dayData = dailyData[dayKey] ?? {
          'steps': 0,
          'calories': 0,
          'workouts': 0,
          'sleep': 0,
          'water': 0,
          'day': DateFormat('EEE').format(date),
        };
        weeklyList.add(dayData);
      }

      setState(() {
        weeklyData = weeklyList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching weekly data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Activity Overview",
              style: GoogleFonts.bebasNeue(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _generateGroups(),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= weeklyData.length) return const SizedBox();
                          return Text(
                            weeklyData[index]["day"],
                            style: GoogleFonts.bebasNeue(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: const [
                _Legend(color: Colors.blue, text: "Steps"),
                _Legend(color: Colors.orange, text: "Calories"),
                _Legend(color: Colors.green, text: "Workouts"),
                _Legend(color: Colors.purple, text: "Sleep"),
                _Legend(color: Colors.cyan, text: "Water"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateGroups() {
    return List.generate(weeklyData.length, (index) {
      final dayData = weeklyData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: dayData["steps"] / 1000, color: Colors.blue, width: 8),
          BarChartRodData(toY: dayData["calories"] / 10, color: Colors.orange, width: 8),
          BarChartRodData(toY: dayData["workouts"] * 2, color: Colors.green, width: 8),
          BarChartRodData(toY: dayData["sleep"], color: Colors.purple, width: 8),
          BarChartRodData(toY: dayData["water"] * 2, color: Colors.cyan, width: 8),
        ],
      );
    });
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.bebasNeue(fontSize: 12)),
      ],
    );
  }
}