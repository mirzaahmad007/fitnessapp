import 'dart:async';
import 'package:fitnessapp/stepshistory.dart';
import 'package:fitnessapp/userscreens/stepshistory.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'daily_record.dart';
import 'history_screen.dart';

class StepsCounterScreen extends StatefulWidget {
  const StepsCounterScreen({Key? key}) : super(key: key);

  @override
  State<StepsCounterScreen> createState() => _StepsCounterScreenState();
}

class _StepsCounterScreenState extends State<StepsCounterScreen> {
  StreamSubscription<StepCount>? _stepCountSubscription;
  int _startSteps = 0;
  int _currentSteps = 0;
  bool _isCounting = false;

  double _calories = 0;
  double _distance = 0;

  late Box<DailyRecord> historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<DailyRecord>('historyBox');
    _loadTodayData();
  }

  // Load today's record if exists
  void _loadTodayData() {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final record = historyBox.get(today);
    if (record != null) {
      setState(() {
        _currentSteps = record.steps;
        _calories = record.calories;
        _distance = record.distance;
      });
    }
  }

  // Save today's record
  void _saveDailyRecord() {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final record = DailyRecord(
      date: today,
      steps: _currentSteps,
      calories: _calories,
      distance: _distance,
    );
    historyBox.put(today, record);
  }

  // Request permission
  Future<void> _requestPermission() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _startStepCounting();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 Permission required to count steps")),
      );
    }
  }

  // Start step counting
  void _startStepCounting() {
    _stepCountSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      setState(() {
        if (_startSteps == 0) {
          _startSteps = event.steps;
        }
        _currentSteps = event.steps - _startSteps;

        _calories = _currentSteps * 0.04; // approx kcal
        _distance = _currentSteps * 0.78 / 1000; // km

        _saveDailyRecord();
      });
    }, onError: (error) {
      debugPrint("Step Count Error: $error");
    });

    setState(() => _isCounting = true);
  }

  // Stop step counting
  void _stopStepCounting() {
    _stepCountSubscription?.cancel();
    _stepCountSubscription = null;

    setState(() {
      _isCounting = false;
      _saveDailyRecord();
    });
  }

  // Reset steps
  void _resetSteps() {
    setState(() {
      _startSteps = 0;
      _currentSteps = 0;
      _calories = 0;
      _distance = 0;
      _saveDailyRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏃 Steps Counter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$_currentSteps steps",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("🔥 Calories: ${_calories.toStringAsFixed(2)} kcal"),
            Text("📏 Distance: ${_distance.toStringAsFixed(2)} km"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isCounting ? null : _requestPermission,
              child: const Text("▶ Start Counting"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isCounting ? _stopStepCounting : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("⏹ Stop Counting"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetSteps,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("🔄 Reset"),
            ),
          ],
        ),
      ),
    );
  }
}