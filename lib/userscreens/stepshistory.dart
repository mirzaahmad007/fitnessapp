import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'daily_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<DailyRecord> historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<DailyRecord>('historyBox');
  }

  @override
  Widget build(BuildContext context) {
    List<DailyRecord> records = historyBox.values.toList();
    // Sort by date descending
    records.sort((a, b) => b.date.compareTo(a.date));
    // Debug print to verify records
    print('Records: ${records.map((r) => {'date': r.date, 'steps': r.steps, 'calories': r.calories, 'distance': r.distance}).toList()}');

    return Scaffold(
      appBar: AppBar(title: const Text("📊 Steps History")),
      body: records.isEmpty
          ? const Center(child: Text("No history yet"))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 📊 Weekly Bar Chart
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (records.isEmpty
                      ? 1000
                      : records
                      .map((r) => r.steps)
                      .reduce((a, b) => a > b ? a : b) +
                      1000)
                      .toDouble(),
                  barGroups: List.generate(
                    records.take(7).length,
                        (index) {
                      final r = records[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: r.steps.toDouble(),
                            color: r.steps >= 10000
                                ? Colors.green
                                : r.steps >= 5000
                                ? Colors.blue
                                : Colors.red,
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < records.take(7).length) {
                            final steps = records[index].steps;
                            final displayText = steps >= 1000
                                ? '${(steps / 1000).toStringAsFixed(1)}k'
                                : steps.toString();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                displayText,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < records.take(7).length) {
                            return Text(
                              DateFormat('dd MMM').format(
                                  DateTime.parse(records[index].date)),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
            const Divider(),
            // 📋 Daily List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('yyyy-MM-dd').format(
                      DateTime.parse(record.date))),
                  subtitle: Text(
                    "Steps: ${record.steps} | 🔥 ${record.calories.toStringAsFixed(1)} kcal | 📏 ${record.distance.toStringAsFixed(2)} km",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}