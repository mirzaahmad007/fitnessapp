// lib/utilires.dart
import 'package:flutter/material.dart';

int createUniqueId() =>
    DateTime.now().millisecondsSinceEpoch.remainder(100000);

class NotificationWeekAndTime {
  final int dayOfTheWeek;   // Monday=1 ... Sunday=7
  final TimeOfDay timeOfDay;

  NotificationWeekAndTime({
    required this.dayOfTheWeek,
    required this.timeOfDay,
  });
}

Future<NotificationWeekAndTime?> pickSchedule(BuildContext context) async {
  const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  int? selectedDay;           // 1..7
  TimeOfDay? selectedTime;

  return await showDialog<NotificationWeekAndTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Pick Schedule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text("Select Day"),
                value: selectedDay,
                items: List.generate(
                  weekdays.length,
                      (i) => DropdownMenuItem(
                    value: i + 1, // Mon=1 ... Sun=7
                    child: Text(weekdays[i]),
                  ),
                ),
                onChanged: (v) => setState(() => selectedDay = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => selectedTime = t);
                },
                child: Text(
                  selectedTime == null
                      ? "Pick Time"
                      : "Time: ${selectedTime!.format(context)}",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDay != null && selectedTime != null) {
                  Navigator.pop(
                    context,
                    NotificationWeekAndTime(
                      dayOfTheWeek: selectedDay!,
                      timeOfDay: selectedTime!,
                    ),
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    },
  );
}
