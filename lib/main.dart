import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'userscreens/Homescreen.dart';
import 'userscreens/daily_record.dart';
import 'userscreens/notificatiocontroller.dart';
import 'userscreens/stepscount.dart';
import 'stepshistory.dart';
import 'userscreens/Splashscreen.dart';
import 'userscreens/loginscreen.dart';
import 'userscreens/phoneauthenScreen.dart';
import 'onboardingwrapper/onboardingflow.dart';

// Controllers
import 'userscreens/notification_controller.dart';

// Custom Theme Extension for Gradients
class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient cardGradient;
  final LinearGradient sidebarGradient;

  AppGradients({
    required this.cardGradient,
    required this.sidebarGradient,
  });

  @override
  AppGradients copyWith({LinearGradient? cardGradient, LinearGradient? sidebarGradient}) {
    return AppGradients(
      cardGradient: cardGradient ?? this.cardGradient,
      sidebarGradient: sidebarGradient ?? this.sidebarGradient,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      sidebarGradient: LinearGradient.lerp(sidebarGradient, other.sidebarGradient, t)!,
    );
  }
}

class ThemeController extends GetxController {
  var isDark = false.obs;

  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBm3PU2xX8FZ1zlb7_G6AzdmxXgAPvlqwQ',
      appId: '1:286764976998:android:9f2ef8028787a97f24d6a7',
      messagingSenderId: '286764976998',
      projectId: 'itnessapp',
      storageBucket: 'itnessapp.firebasestorage.app',
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DailyRecordAdapter());
  await Hive.openBox<DailyRecord>('historyBox');

  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'General notifications',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'schedule_channel',
        channelName: 'Scheduled Notifications',
        channelDescription: 'Scheduled notification tests',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'steps_channel',
        channelName: 'Steps Notifications',
        channelDescription: 'Reminders for daily steps',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'diet_channel',
        channelName: 'Diet Notifications',
        channelDescription: 'Meal and diet reminders',
        defaultColor: Colors.orange,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'sleep_channel',
        channelName: 'Sleep Notifications',
        channelDescription: 'Sleep schedule reminders',
        defaultColor: Colors.indigo,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'workout_channel',
        channelName: 'Workout Notifications',
        channelDescription: 'Daily workout reminders',
        defaultColor: Colors.red,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
    ],
    debug: true,
  );

  // Register Notification Listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
  );

  // Request permission for notifications
  if (!await AwesomeNotifications().isNotificationAllowed()) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<Widget> _decideStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    } else {
      final prefs = await SharedPreferences.getInstance();
      bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;
      if (isFirstLogin) {
        return const OnboardingFlow();
      } else {
        return FitnessHomePage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        primaryColor: Colors.blue[700],
        dividerColor: Colors.grey[300],
        textTheme: GoogleFonts.bebasNeueTextTheme(
          TextTheme(
            bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
            bodyMedium: TextStyle(color: Colors.grey[700], fontSize: 14),
            titleLarge: TextStyle(color: Colors.blue[800], fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue[700]),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          titleTextStyle: GoogleFonts.bebasNeue(fontSize: 18, color: Colors.white),
        ),
        extensions: [
          AppGradients(
            cardGradient: LinearGradient(
              colors: [Colors.white70, Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            ),
            sidebarGradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        primaryColor: Colors.blue[300],
        dividerColor: Colors.grey[700],
        textTheme: GoogleFonts.bebasNeueTextTheme(
          TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
            bodyMedium: TextStyle(color: Colors.grey[300], fontSize: 14),
            titleLarge: TextStyle(color: Colors.blue[300], fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue[300]),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[900],
          titleTextStyle: GoogleFonts.bebasNeue(fontSize: 18, color: Colors.white),
        ),
        extensions: [
          AppGradients(
            cardGradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.grey[900]!],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            ),
            sidebarGradient: LinearGradient(
              colors: [Colors.blueGrey[700]!, Colors.blueGrey[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
      themeMode: themeController.isDark.value ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<Widget>(
        future: _decideStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splashscreen();
          }
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const LoginScreen();
        },
      ),
    ));
  }
}