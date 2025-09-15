import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' show sin, pi;

// Repository interface
abstract class WaterRepository {
  Future<void> saveDailyGoal(double dailyGoalMl);
  Future<double> loadDailyGoal();
  Future<void> saveTodayIntake(String dateKey, double intakeMl);
  Future<double> loadTodayIntake(String dateKey);
  Future<void> saveHistory(List<DayRecord> history);
  Future<List<DayRecord>> loadHistory();
}

// Firestore implementation
class FirestoreWaterRepository implements WaterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;
  DocumentReference get _waterDoc => _firestore.collection('Water').doc(_userId);

  FirestoreWaterRepository() : _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<void> saveDailyGoal(double dailyGoalMl) async {
    try {
      await _waterDoc.set(
        {'dailyGoalMl': dailyGoalMl},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save daily goal: $e');
    }
  }

  @override
  Future<double> loadDailyGoal() async {
    try {
      final doc = await _waterDoc.get();
      if (!doc.exists) {
        await _waterDoc.set(
          {'dailyGoalMl': 2000.0},
          SetOptions(merge: true),
        );
        return 2000.0;
      }
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['dailyGoalMl'] as num?)?.toDouble() ?? 2000.0;
    } catch (e) {
      throw Exception('Failed to load daily goal: $e');
    }
  }

  @override
  Future<void> saveTodayIntake(String dateKey, double intakeMl) async {
    try {
      final dateStr = dateKey.replaceAll('intake_', '').replaceAll('_', '-');
      await _waterDoc.set(
        {
          'currentDate': dateStr,
          'currentIntakeMl': intakeMl,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save today intake: $e');
    }
  }

  @override
  Future<double> loadTodayIntake(String dateKey) async {
    try {
      final docRef = _waterDoc;
      final doc = await docRef.get();
      if (!doc.exists) {
        final todayStr = _getTodayStr();
        await docRef.set({
          'userId': _userId,
          'dailyGoalMl': 2000.0,
          'currentDate': todayStr,
          'currentIntakeMl': 0.0,
          'history': <Map<String, dynamic>>[],
        });
        return 0.0;
      }
      final data = doc.data() as Map<String, dynamic>?;
      final storedDateStr = data?['currentDate'] as String?;
      final todayStr = _getTodayStr();
      double intake = (data?['currentIntakeMl'] as num?)?.toDouble() ?? 0.0;
      List<dynamic> historyList = data?['history'] as List<dynamic>? ?? [];

      if (storedDateStr != todayStr) {
        if (intake > 0) {
          final prevDate = DateTime.parse('${storedDateStr ?? todayStr}T00:00:00');
          final prevRecord = DayRecord(date: prevDate, intakeMl: intake.toInt()).toJson();
          historyList.add(prevRecord);
          List<DayRecord> tempHist = historyList.map((json) => DayRecord.fromJson(json as Map<String, dynamic>)).toList();
          tempHist.sort((a, b) => b.date.compareTo(a.date));
          final limitedHist = tempHist.take(30).toList();
          historyList = limitedHist.map((r) => r.toJson()).toList();
        }
        await docRef.update({
          'currentDate': todayStr,
          'currentIntakeMl': 0.0,
          'history': historyList,
        });
        intake = 0.0;
      }
      return intake;
    } catch (e) {
      throw Exception('Failed to load today intake: $e');
    }
  }

  String _getTodayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> saveHistory(List<DayRecord> history) async {
    try {
      final limitedHistory = history.take(30).toList();
      await _waterDoc.set(
        {'history': limitedHistory.map((r) => r.toJson()).toList()},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save history: $e');
    }
  }

  @override
  Future<List<DayRecord>> loadHistory() async {
    try {
      final doc = await _waterDoc.get();
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>?;
      final histData = data?['history'] as List<dynamic>? ?? [];
      List<DayRecord> history = histData.map((json) => DayRecord.fromJson(json as Map<String, dynamic>)).toList();
      history.sort((a, b) => b.date.compareTo(a.date));
      return history;
    } catch (e) {
      throw Exception('Failed to load history: $e');
    }
  }
}

class WaterPage extends StatefulWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> with SingleTickerProviderStateMixin {
  double dailyGoalMl = 2000;
  double todayIntakeMl = 0;
  List<DayRecord> history = [];
  late WaterRepository _repository;

  final List<int> quickOptions = [200, 500, 250];
  final Map<String, int> unitOptions = {
    'Glass (250ml)': 250,
    'Bottle (1000ml)': 1000,
  };

  AnimationController? _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _repository = FirestoreWaterRepository();
    _loadData();
  }

  @override
  void dispose() {
    _waveController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        dailyGoalMl = 2000;
        todayIntakeMl = 0;
        history = [];
      });
      final goal = await _repository.loadDailyGoal();
      final intake = await _repository.loadTodayIntake(_todayKey());
      final hist = await _repository.loadHistory();
      setState(() {
        dailyGoalMl = goal;
        todayIntakeMl = intake;
        history = hist;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return 'intake_${year}_${month}_${day}';
  }

  Future<void> _saveToday() async {
    try {
      await _repository.saveDailyGoal(dailyGoalMl);
      await _repository.saveTodayIntake(_todayKey(), todayIntakeMl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  Future<void> _addIntake(int ml) async {
    setState(() {
      todayIntakeMl += ml;
      if (todayIntakeMl < 0) todayIntakeMl = 0;
    });
    await _saveToday();
  }

  Future<void> _setCustomGoal() async {
    final controller = TextEditingController(text: (dailyGoalMl / 1000).toString());
    final res = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Daily Goal (Liters)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'e.g. 2.5',
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
          ),
          style: GoogleFonts.poppins(color: Colors.blue.shade900),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.blue.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: Colors.blue.shade200,
              elevation: 5,
            ),
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(context, val);
            },
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (res != null) {
      setState(() {
        dailyGoalMl = res * 1000;
      });
      await _saveToday();
    }
  }

  Future<void> _addCustomIntake() async {
    final controller = TextEditingController();
    final res = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom Water (ml)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 350',
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
          ),
          style: GoogleFonts.poppins(color: Colors.blue.shade900),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.blue.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: Colors.blue.shade200,
              elevation: 5,
            ),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(context, val);
            },
            child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (res != null) await _addIntake(res);
  }

  double get progress => (todayIntakeMl / dailyGoalMl).clamp(0, 1).toDouble();

  Future<void> _resetToday() async {
    setState(() {
      todayIntakeMl = 0;
    });
    await _saveToday();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                  child: Column(
                    children: [
                      FadeInDown(
                        child: AppBar(
                          title: Text(
                            'Water Tracker',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 28 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          actions: [
                            IconButton(
                              onPressed: _setCustomGoal,
                              icon: const Icon(Icons.settings, color: Colors.white),
                              iconSize: isTablet ? 30 : 24,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 30 : 20),
                      FadeInUp(
                        child: _waveController == null
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : WaterBottle(
                          progress: progress,
                          waveController: _waveController!,
                          width: isTablet ? 200 : isLandscape ? screenWidth * 0.3 : 140,
                          height: isTablet ? 400 : isLandscape ? screenHeight * 0.5 : 280,
                        ),
                      ),
                      SizedBox(height: isTablet ? 30 : 20),
                      Text(
                        '${(todayIntakeMl / 1000).toStringAsFixed(2)} L / ${(dailyGoalMl / 1000).toStringAsFixed(2)} L',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isTablet ? 30 : 24),
                      Wrap(
                        spacing: isTablet ? 16 : 12,
                        runSpacing: isTablet ? 12 : 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ...quickOptions.map((q) => _buildGlassButton('+${q} ml', () => _addIntake(q), isTablet)),
                          ...unitOptions.entries.map((e) => _buildGlassButton('+1 ${e.key}', () => _addIntake(e.value), isTablet)),
                          _buildGlassButton('Custom', _addCustomIntake, isTablet),
                        ],
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today progress: ${(progress * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: _resetToday,
                            child: Text(
                              'Reset',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      const Divider(color: Colors.white54),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Last 7 Days',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      SizedBox(
                        height: isTablet ? 400 : isLandscape ? screenHeight * 0.4 : 200,
                        child: _buildHistoryList(isTablet),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(String text, VoidCallback onPressed, bool isTablet) {
    return BounceInDown(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 16 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(bool isTablet) {
    final last7 = history.take(7).toList();
    if (last7.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 18 : 16,
            color: Colors.white,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: last7.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white54),
      itemBuilder: (context, index) {
        final day = last7[index];
        final pct = (day.intakeMl / dailyGoalMl).clamp(0, 1).toDouble();
        return FadeInRight(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: ListTile(
              title: Text(
                _formatDate(day.date),
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '${(day.intakeMl / 1000).toStringAsFixed(2)} L',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              trailing: SizedBox(
                width: isTablet ? 120 : 90,
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    if (DateTime.now().difference(d).inDays == 0) return 'Today';
    if (DateTime.now().difference(d).inDays == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class DayRecord {
  DateTime date;
  int intakeMl;
  DayRecord({required this.date, required this.intakeMl});

  bool isSameDay(DateTime other) =>
      date.year == other.year && date.month == other.month && date.day == other.day;

  Map<String, dynamic> toJson() =>
      {'date': date.toIso8601String(), 'intakeMl': intakeMl};

  factory DayRecord.fromJson(Map<String, dynamic> j) =>
      DayRecord(date: DateTime.parse(j['date']), intakeMl: j['intakeMl'] as int);
}

class WaterBottle extends StatelessWidget {
  final double progress;
  final AnimationController waveController;
  final double width;
  final double height;

  const WaterBottle({
    Key? key,
    required this.progress,
    required this.waveController,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CustomPaint(
                  size: Size(width - 8, height - 8),
                  painter: WaterWavePainter(
                    progress: progress,
                    animationValue: waveController.value,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.blue.shade900.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double progress;
  final double animationValue;

  WaterWavePainter({required this.progress, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * (1 - progress);
    final waveAmplitude = size.height * 0.06;
    final waveFrequency = 0.05;

    path.moveTo(0, waveHeight);
    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight +
          sin((x * waveFrequency + animationValue * 2 * pi)) * waveAmplitude +
          sin((x * waveFrequency * 1.5 + animationValue * 2 * pi)) * (waveAmplitude * 0.5);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final glowPath = Path();
    glowPath.moveTo(0, waveHeight + waveAmplitude);
    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight +
          sin((x * waveFrequency + animationValue * 2 * pi)) * waveAmplitude * 1.2;
      glowPath.lineTo(x, y);
    }
    glowPath.lineTo(size.width, size.height);
    glowPath.lineTo(0, size.height);
    glowPath.close();
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}