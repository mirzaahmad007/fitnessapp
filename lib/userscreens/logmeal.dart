import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Meal {
  final String type;
  final String description;
  final int calories;

  Meal({required this.type, required this.description, required this.calories});
}

class MealTracker extends StatefulWidget {
  const MealTracker({super.key});

  @override
  State<MealTracker> createState() => _MealTrackerState();
}

class _MealTrackerState extends State<MealTracker> {
  final List<Meal> _meals = [];
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  String _selectedMeal = "Breakfast";

  void _addMeal() {
    if (_descController.text.isEmpty || _calController.text.isEmpty) return;

    setState(() {
      _meals.add(
        Meal(
          type: _selectedMeal,
          description: _descController.text,
          calories: int.tryParse(_calController.text) ?? 0,
        ),
      );
    });

    _descController.clear();
    _calController.clear();
    Navigator.pop(context);
  }

  void _openMealDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Log a Meal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMeal,
                items: ["Breakfast", "Lunch", "Dinner", "Snacks"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMeal = val!),
                decoration: const InputDecoration(labelText: "Meal Type"),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: _calController,
                decoration: const InputDecoration(labelText: "Calories"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addMeal, child: const Text("Add")),
        ],
      ),
    );
  }

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + m.calories);

  @override
  Widget build(BuildContext context) {
    // Set a maximum calorie value for the CircularPercentIndicator
    const double maxCalories = 5000.0; // Arbitrary max for visual scaling
    final double progress = (_totalCalories / maxCalories).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Meal Tracker 🍽"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Total Calories in CircularPercentIndicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularPercentIndicator(
              radius: 90.0,
              lineWidth: 12.0,
              animation: true,
              percent: progress, // Visual representation of calories
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$_totalCalories cal",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    "Total Calories",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.green,
              backgroundColor: Colors.green.withOpacity(0.2),
            ),
          ),

          // Meals List
          Expanded(
            child: _meals.isEmpty
                ? Center(
              child: Text(
                "No meals logged yet!",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        meal.type[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(meal.type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    subtitle: Text(meal.description, style: GoogleFonts.poppins()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${meal.calories} cal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _meals.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _openMealDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}