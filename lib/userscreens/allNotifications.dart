import 'package:flutter/material.dart';
import 'package:fitnessapp/userscreens/utilires.dart';   // 🔹 for pickSchedule()
import 'package:fitnessapp/userscreens/notifyfun.dart';

import 'notification.dart'; // 🔹 for create notifications & cancel

/// Dashboard Screen
class ALLNotification extends StatelessWidget {
  const ALLNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "Steps", "icon": Icons.directions_walk, "color": Colors.blue, "channel": "steps_channel"},
      {"title": "Diet", "icon": Icons.restaurant_menu, "color": Colors.green, "channel": "diet_channel"},
      {"title": "Sleep", "icon": Icons.nights_stay, "color": Colors.indigo, "channel": "sleep_channel"},
      {"title": "Workout", "icon": Icons.fitness_center, "color": Colors.orange, "channel": "workout_channel"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Fitness Dashboard"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 per row
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _DashboardContainer(
            title: item["title"],
            icon: item["icon"],
            color: item["color"],
            channelKey: item["channel"],
          );
        },
      ),
    );
  }
}

/// Custom Container Widget
class _DashboardContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String channelKey;

  const _DashboardContainer({
    required this.title,
    required this.icon,
    required this.color,
    required this.channelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            /// Buttons Row
            Row(
              children: [
                // Set Time Button
                Expanded(
                  child: _GradientButton(
                    text: "Set Time",
                    gradientColors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                    onTap: () async {
                      final schedule = await pickSchedule(context);
                      if (schedule != null) {
                        // 🔹 create notification based on channel
                        switch (channelKey) {
                          case "steps_channel":
                            await createStepsNotification(schedule);
                            break;
                          case "diet_channel":
                            await createDietNotification(schedule);
                            break;
                          case "sleep_channel":
                            await createSleepNotification(schedule);
                            break;
                          case "workout_channel":
                            await createWorkoutNotification(schedule);
                            break;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$title notification set!")),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 5),
                // Cancel Button
                Expanded(
                  child: _GradientButton(
                    text: "Cancel",
                    gradientColors: [Colors.redAccent, Colors.red.shade400],
                    onTap: () async {
                      await cancelAllScheduleNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$title notification cancelled!")),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient Button Widget
class _GradientButton extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
