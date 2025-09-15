import 'package:flutter/material.dart';


class DietCardsApp extends StatelessWidget {
  const DietCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Diet Plan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const DietCardScreen(),
    );
  }
}

/// Meal Model
class Meal {
  final String title;
  final List<String> items;

  Meal({required this.title, required this.items});
}

/// Best Fitness Diet Plan (example)
final List<Meal> fitnessMeals = [
  Meal(
    title: "Breakfast 🥚",
    items: [
      "6 Egg Whites + 2 Whole Eggs",
      "1 Cup Oats with Almonds",
      "1 Banana",
      "Black Coffee / Green Tea",
    ],
  ),
  Meal(
    title: "Mid-Morning Snack 🍎",
    items: [
      "Apple or Seasonal Fruit",
      "Handful of Almonds / Walnuts",
      "1 Scoop Whey Protein (optional)",
    ],
  ),
  Meal(
    title: "Lunch 🍗",
    items: [
      "200g Grilled Chicken / Paneer / Fish",
      "1 Cup Brown Rice / Quinoa",
      "Steamed Broccoli & Spinach",
      "Green Salad with Olive Oil",
    ],
  ),
  Meal(
    title: "Pre-Workout ⚡",
    items: [
      "2 Slices Brown Bread with Peanut Butter",
      "1 Banana",
      "Black Coffee (optional)",
    ],
  ),
  Meal(
    title: "Post-Workout Recovery 🥤",
    items: [
      "1 Scoop Whey Protein + Water",
      "5 Dates or 1 Banana",
    ],
  ),
  Meal(
    title: "Dinner 🥗",
    items: [
      "150g Grilled Salmon / Chicken / Paneer",
      "2 Chapati (whole wheat)",
      "Mixed Veggies (Zucchini, Carrots, Beans)",
      "1 Bowl Daal / Lentils",
    ],
  ),
];

/// UI Screen
class DietCardScreen extends StatelessWidget {
  const DietCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Best Fitness Diet Plan 💪"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fitnessMeals.length,
        itemBuilder: (context, index) {
          final meal = fitnessMeals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Title
                  Text(
                    meal.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Food items
                  ...meal.items.map(
                        (item) => Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.done),
                      label: const Text("Mark as eaten"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
