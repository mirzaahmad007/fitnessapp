import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/userscreens/utilires.dart';

import 'detailnotify.dart';
import 'notification.dart'; // 🔹 yaha tumhare notification functions hain

class NotifyFun extends StatefulWidget {
  const NotifyFun({super.key});

  @override
  State<NotifyFun> createState() => _NotifyFunState();
}

class _NotifyFunState extends State<NotifyFun> {
  @override
  void initState() {
    super.initState();

    /// 🔹 Permission Check
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Allow Notification"),
            content: const Text("Our app would like to send you Notifications"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Don't allow",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) => Navigator.pop(context)),
                child: const Text(
                  "Allow",
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  /// 🔹 Helper to pick time and create notification
  Future<void> _setNotification(
      BuildContext context, Function(NotificationWeekAndTime) createFn) async {
    NotificationWeekAndTime? pickedSchedule = await pickSchedule(context);

    if (pickedSchedule != null) {
      await createFn(pickedSchedule);

      final dayNames = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⏰ Alarm set for ${dayNames[pickedSchedule.dayOfTheWeek - 1]} "
                "at ${pickedSchedule.timeOfDay.format(context)}",
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  Detailnotify()),
            ),
            icon: const Icon(Icons.insert_chart_outlined,
                size: 18, color: Colors.orange),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Image(
              image: AssetImage("assets/images/plant.png"),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            /// Plant Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: createPlantFoodNotification,
                  child: const Text("Plant Food"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => _setNotification(
                      context, createWaterPlanatNotification),
                  child: const Text("Water"),
                ),
              ],
            ),

            const Divider(height: 40),

            /// Fitness Reminders
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _setNotification(context, createStepsNotification),
                  child: const Text("Steps"),
                ),
                ElevatedButton(
                  onPressed: () => _setNotification(context, createDietNotification),
                  child: const Text("Diet"),
                ),
                ElevatedButton(
                  onPressed: () => _setNotification(context, createSleepNotification),
                  child: const Text("Sleep"),
                ),
                ElevatedButton(
                  onPressed: () => _setNotification(context, createWorkoutNotification),
                  child: const Text("Workout"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                await cancelAllScheduleNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🚫 All alarms cancelled"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Cancel All"),
            ),
          ],
        ),
      ),
    );
  }
}
