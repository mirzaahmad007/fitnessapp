import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/openrouter.dart';
import '../services/openrouter_service.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final OpenRouterService api = OpenRouterService();

  String _fitnessLevel = "beginner";
  String _targetMuscle = "full body";
  String _equipment = "none";

  bool _loading = false;
  List<Map<String, dynamic>> _workout = [];

  /// Generate AI Workout
  Future<void> _generateWorkout() async {
    setState(() => _loading = true);

    final result = await api.generateWorkout(
      fitnessLevel: _fitnessLevel,
      targetMuscle: _targetMuscle,
      equipment: _equipment,
    );

    setState(() {
      _workout = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI Workout Coach",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _selectionControls(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _generateWorkout,
              child: Text("Generate Workout"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 16),
            _loading
                ? CircularProgressIndicator(color: Colors.deepPurple)
                : _workoutList(),
          ],
        ),
      ),
    );
  }

  /// Dropdowns for fitness level, target muscle, equipment
  Widget _selectionControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown("Fitness Level", ["beginner", "intermediate", "advanced"],
            _fitnessLevel, (val) => setState(() => _fitnessLevel = val)),
        _dropdown("Target Muscle", [
          "full body",
          "upper body",
          "lower body",
          "core"
        ], _targetMuscle, (val) => setState(() => _targetMuscle = val)),
        _dropdown("Equipment", ["none", "dumbbells", "resistance bands", "full gym"],
            _equipment, (val) => setState(() => _equipment = val)),
      ],
    );
  }

  Widget _dropdown(
      String label, List<String> items, String selected, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ", style: GoogleFonts.poppins(fontSize: 16)),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: selected,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => val != null ? onChanged(val) : null,
          ),
        ],
      ),
    );
  }

  /// Display generated workout
  Widget _workoutList() {
    if (_workout.isEmpty) {
      return Text("Your workout plan will appear here.",
          style: GoogleFonts.poppins());
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _workout.length,
        itemBuilder: (_, index) {
          final w = _workout[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            child: ListTile(
              title: Text(w['exercise'] ?? "Exercise",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                "Sets: ${w['sets'] ?? "-"} | Reps: ${w['reps'] ?? "-"} | Rest: ${w['rest_seconds'] ?? "-"} sec",
                style: GoogleFonts.poppins(),
              ),
            ),
          );
        },
      ),
    );
  }
}
