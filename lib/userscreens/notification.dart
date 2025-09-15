import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fitnessapp/userscreens/utilires.dart';

/// 🔹 Helper function for scheduling
NotificationCalendar buildSchedule(NotificationWeekAndTime notificationSchedule) {
  return NotificationCalendar(
    weekday: notificationSchedule.dayOfTheWeek,
    hour: notificationSchedule.timeOfDay.hour,
    minute: notificationSchedule.timeOfDay.minute,
    second: 0,
    millisecond: 0,
    repeats: true,
    allowWhileIdle: true, // ✅ Background me trigger hoga
  );
}

/// 🔹 Plant notification (instant)
Future<void> createPlantFoodNotification() async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "basic_channel",
        title: "${Emojis.money_money_bag} ${Emojis.plant_cactus} Buy plant Food!!!",
        body: "Florist at 3 am",
        bigPicture: "asset://assets/images/plant.png", // ✅ asset:// prefix
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
    print("🌱 Plant food notification created");
  } catch (e) {
    print("❌ Error creating plant food notification: $e");
  }
}

/// 🔹 Plant water notification (scheduled)
Future<void> createWaterPlanatNotification(NotificationWeekAndTime notificationSchedule) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "schedule_channel",
        title: "${Emojis.wheater_water_wave} Add some water to your plant!!",
        body: "Water your plants regularly to keep them healthy",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "MARK-DONE",
          label: "${Emojis.activites_moon_viewing_ceremony} Mark Done",
        )
      ],
      schedule: buildSchedule(notificationSchedule),
    );
    print("💧 Plant water notification scheduled");
  } catch (e) {
    print("❌ Error scheduling plant water notification: $e");
  }
}

/// 🔹 STEPS Notification
Future<void> createStepsNotification(NotificationWeekAndTime notificationSchedule) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "steps_channel",
        title: "${Emojis.clothing_running_shoe} Time to Walk!",
        body: "Complete your daily steps to stay active 💪",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(key: "MARK-DONE", label: "Mark Done ✅"),
      ],
      schedule: buildSchedule(notificationSchedule),
    );
    print("👟 Steps notification scheduled");
  } catch (e) {
    print("❌ Error scheduling steps notification: $e");
  }
}

/// 🔹 DIET Notification
Future<void> createDietNotification(NotificationWeekAndTime notificationSchedule) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "diet_channel",
        title: "${Emojis.food_green_salad} Healthy Meal Time!",
        body: "Don't skip your diet plan 🥗",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(key: "MARK-DONE", label: "Ate it ✅"),
      ],
      schedule: buildSchedule(notificationSchedule),
    );
    print("🥗 Diet notification scheduled");
  } catch (e) {
    print("❌ Error scheduling diet notification: $e");
  }
}

/// 🔹 SLEEP Notification
Future<void> createSleepNotification(NotificationWeekAndTime notificationSchedule) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "sleep_channel",
        title: "${Emojis.wheater_thermometer} Sleep Reminder",
        body: "Time to get good rest 💤",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(key: "MARK-DONE", label: "Went to Sleep 😴"),
      ],
      schedule: buildSchedule(notificationSchedule),
    );
    print("😴 Sleep notification scheduled");
  } catch (e) {
    print("❌ Error scheduling sleep notification: $e");
  }
}

/// 🔹 WORKOUT Notification
Future<void> createWorkoutNotification(NotificationWeekAndTime notificationSchedule) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: "workout_channel",
        title: "${Emojis.person_sport_man_juggling} Workout Time!",
        body: "Let's crush today's workout 🏋️",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(key: "MARK-DONE", label: "Workout Done ✅"),
      ],
      schedule: buildSchedule(notificationSchedule),
    );
    print("🏋️ Workout notification scheduled");
  } catch (e) {
    print("❌ Error scheduling workout notification: $e");
  }
}

/// 🔹 Cancel all notifications
Future<void> cancelAllScheduleNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
  print("🛑 All scheduled notifications cancelled");
}
