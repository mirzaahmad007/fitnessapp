import 'package:fitnessapp/userscreens/stepshistory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/userscreens/loginscreen.dart';
import '../stepshistory.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({Key? key}) : super(key: key);

  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> with SingleTickerProviderStateMixin {
  Stream<StepCount>? _stepCountStream;
  int _loadedBaseSteps = 0;  // Loaded total steps for today from Firestore
  int _startAbsoluteSteps = 0;  // Absolute steps at session start
  int _currentSteps = 0;
  bool _isCounting = false;
  bool _isInitializing = true;
  bool _initializationFailed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double get distanceKm => _currentSteps * 0.0008; // 1 step ~ 0.8m
  double get calories => _currentSteps * 0.04; // Approx 0.04 kcal/step

  String get _docId => '${_auth.currentUser!.uid}_$_today';  // Fixed ID for single doc per day

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      if (_auth.currentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please sign in to track steps'),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      } else {
        await _loadTodayRecord();
      }
      setState(() {
        _isInitializing = false;
        _initializationFailed = false;
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        _isInitializing = false;
        _initializationFailed = true;
      });
    }
  }

  Future<void> _loadTodayRecord() async {
    try {
      final docRef = _firestore.collection('steps').doc(_docId);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _loadedBaseSteps = data['steps'] ?? 0;
          _currentSteps = _loadedBaseSteps;  // Start with loaded total
        });
      } else {
        setState(() {
          _loadedBaseSteps = 0;
          _currentSteps = 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading today\'s record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading steps: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() {
        _loadedBaseSteps = 0;
        _currentSteps = 0;
      });
    }
  }

  void _startCounting() {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to start tracking steps'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream!.listen(
          (StepCount event) {
        if (_isCounting) {
          setState(() {
            if (_startAbsoluteSteps == 0) {
              // First event: set start absolute
              _startAbsoluteSteps = event.steps;
            } else {
              // Subsequent: calculate delta and add to base
              int delta = event.steps - _startAbsoluteSteps;
              _currentSteps = _loadedBaseSteps + delta;
            }
          });
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pedometer Error: $error")),
        );
      },
    );
    setState(() {
      _isCounting = true;
      _startAbsoluteSteps = 0;  // Reset for new session
      _animationController.repeat(reverse: true);
    });
  }

  void _stopCounting() {
    setState(() {
      _isCounting = false;
      _animationController.stop();
    });
    // Auto-save on stop to persist the total
    _saveRecord();
  }

  Future<void> _saveRecord() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save steps'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    try {
      final docRef = _firestore.collection('steps').doc(_docId);
      final data = {
        'userId': _auth.currentUser!.uid,
        'date': _today,
        'steps': _currentSteps,  // Save the total daily steps
        'distance': distanceKm,
        'calories': calories,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Always set (merge true) to update or create the single doc
      await docRef.set(data, SetOptions(merge: true));

      // Update local base for next session
      setState(() {
        _loadedBaseSteps = _currentSteps;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Steps saved!'),
            backgroundColor: Colors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Firestore error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving steps: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isInitializing
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
              : _initializationFailed
              ? Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to initialize',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please check your setup or try again.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isInitializing = true;
                          _initializationFailed = false;
                        });
                        _initializeScreen();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B48FF), Color(0xFF00DDEB)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : _auth.currentUser == null
              ? Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign-In Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please sign in to track and save your steps.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B48FF), Color(0xFF00DDEB)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink.shade100, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _isCounting
                            ? Image.network(
                          "https://i.pinimg.com/originals/9e/3d/33/9e3d33d5b3f3829d01e12f77bce789e1.gif",
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.directions_run,
                            size: 120,
                            color: Colors.white70,
                          ),
                        )
                            : const Icon(
                          Icons.directions_run,
                          size: 120,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '$_currentSteps',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const Text(
                          'Steps Today',
                          style: TextStyle(fontSize: 24, color: Colors.teal),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMetricCard('Distance', '${distanceKm.toStringAsFixed(2)} km'),
                            _buildMetricCard('Calories', '${calories.toStringAsFixed(1)} kcal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isCounting ? _stopCounting : _startCounting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCounting ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          _isCounting ? 'Stop' : 'Start',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _saveRecord,  // Now always available, as it updates the total
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                  child: const Text(
                    'View History',
                    style: TextStyle(fontSize: 16, color: Colors.white, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}