import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fitnessapp/userscreens/sleeptrck.dart';
import 'package:fitnessapp/userscreens/stepscount.dart';
import 'package:flutter/material.dart';
import 'dietscreen.dart';
import '../exerceies/bodypartsscreen.dart';
import '../main.dart'; // ✅ navigatorKey access ke liye
import 'steps_screen.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("✅ Notification Created: ${receivedNotification.title}");
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("📢 Notification Displayed: ${receivedNotification.title}");
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("❌ Notification Dismissed: ${receivedAction.id}");
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("👉 Notification Clicked: ${receivedAction.id}");

    try {
      final navigator = MyApp.navigatorKey.currentState;

      if (navigator == null) {
        debugPrint("⚠️ Navigator key is null, app might be terminated.");
        return;
      }

      // ✅ channelKey se decide karo kahan navigate karna hai
      switch (receivedAction.channelKey) {
        case "steps_channel":
          navigator.push(
            MaterialPageRoute(builder: (_) => StepsScreen()),
          );
          break;

        case "diet_channel":
          navigator.push(
            MaterialPageRoute(builder: (_) => DietCardsApp()),
          );
          break;

        case "sleep_channel":
          navigator.push(
            MaterialPageRoute(builder: (_) => SleepTracker()),
          );
          break;

        case "workout_channel":
          navigator.push(
            MaterialPageRoute(builder: (_) => Bodypartsscreen()),
          );
          break;

        default:
          debugPrint("⚠️ Unknown channelKey: ${receivedAction.channelKey}");
      }
    } catch (e) {
      debugPrint("❌ Error while navigating from notification: $e");
    }
  }
}
