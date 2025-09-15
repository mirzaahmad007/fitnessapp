import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/services/bmidtafetch.dart';
import 'package:fitnessapp/services/sleep.dart';
import 'package:fitnessapp/userscreens/sleeptrck.dart';
import 'package:fitnessapp/userscreens/steps_screen.dart';
import 'package:fitnessapp/userscreens/stepscount.dart';
import 'package:fitnessapp/theme/thmeecon.dart' hide ThemeController, AppGradients;
import 'package:fitnessapp/userscreens/loginscreen.dart';
import 'package:fitnessapp/userscreens/userscreens/ProfileEditPage.dart';
import 'package:fitnessapp/userscreens/waterpage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import '../ai/chatbot.dart';
import '../ai/food_recognization.dart';
import 'allNotifications.dart';
import 'bmiscreen.dart';
import 'dietscreen.dart';
import '../exerceies/bodypartsscreen.dart';
import 'history.dart';
import '../homescreen/weeklychart.dart' hide WeeklyChart;
import 'logmeal.dart';
import '../main.dart';
import 'meal_tracker.dart';
import 'sleep_tracker_screen.dart';
import 'daily_record.dart';
import 'bmi_gauge.dart';
import 'sleep_service.dart';

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key});

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  final ThemeController themeController = Get.find<ThemeController>();
  final _sidebarController = SidebarXController(selectedIndex: 0, extended: true);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user signed in');
      return null;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      debugPrint('No user document found for UID: ${user.uid}');
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchTodaySteps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snapshot = await FirebaseFirestore.instance
          .collection('steps')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return {'steps': 0, 'distance': 0.0, 'calories': 0.0};
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching steps: $e')),
        );
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchWaterData() async {
    final repo = FirestoreWaterRepository();
    final todayKey = 'intake_${DateFormat('yyyy_MM_dd').format(DateTime.now())}';
    try {
      final dailyGoal = await repo.loadDailyGoal();
      final todayIntake = await repo.loadTodayIntake(todayKey);
      return {'dailyGoalMl': dailyGoal, 'todayIntakeMl': todayIntake};
    } catch (e) {
      debugPrint('Error fetching water data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching water data: $e')),
        );
      }
      return {'dailyGoalMl': 2000.0, 'todayIntakeMl': 0.0};
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
    await Future.wait([
      _fetchUserData(),
      _fetchTodaySteps(),
      _fetchWaterData(),
      SleepService().getSleepData(),
    ]);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _navigateToBMICalculator(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to access BMI features')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BMICalculatorScreen()));
    }
  }

  void _navigateToStepsScreen(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to access Steps')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StepsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String greeting = now.hour < 12
        ? "Good Morning"
        : now.hour < 18
        ? "Good Afternoon"
        : "Good Evening";
    final IconData greetingIcon = now.hour < 12
        ? Icons.wb_sunny
        : now.hour < 18
        ? Icons.cloud
        : Icons.nightlight_round;
    final String today = DateFormat('yyyy-MM-dd').format(now);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize = screenWidth * 0.05;
    final double avatarRadius = screenWidth * 0.08;
    final double cardPadding = screenWidth * 0.04;

    final historyBox = Hive.box<DailyRecord>('historyBox');
    final todayRecord = historyBox.values.firstWhere(
          (record) => record.date == today,
      orElse: () => DailyRecord(date: today, steps: 0, calories: 0.0, distance: 0.0),
    );

    final List<DateTime> dateList = List.generate(7, (index) => now.add(Duration(days: index - 3)));
    final appGradients = Theme.of(context).extension<AppGradients>()!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        String userName = "Guest";
        String imageUrl = "https://via.placeholder.com/150";
        String userId = "";

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          userName = snapshot.data!['name']?.toString() ?? "Guest";
          imageUrl = (snapshot.data!['imageUrl'] as String?)?.isNotEmpty == true
              ? snapshot.data!['imageUrl'] as String
              : "https://via.placeholder.com/150";
          userId = snapshot.data!['userId']?.toString() ?? "";
        } else if (snapshot.hasError || FirebaseAuth.instance.currentUser == null) {
          userName = "Guest";
          imageUrl = "https://via.placeholder.com/150";
          userId = "";
          if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading user data: ${snapshot.error}')),
            );
          }
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("FitTrack", style: Theme.of(context).appBarTheme.titleTextStyle),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: SafeArea(
            child: SidebarX(
              controller: _sidebarController,
              theme: SidebarXTheme(
                width: 80,
                hoverColor: Colors.redAccent,
                decoration: BoxDecoration(
                  gradient: appGradients.sidebarGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isLightMode ? Colors.black87 : Colors.white,
                  fontSize: baseFontSize * 0.9,
                ),
                selectedTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isLightMode ? Colors.black : Colors.white,
                  fontSize: baseFontSize * 0.9,
                ),
                iconTheme: IconThemeData(
                  color: isLightMode ? Colors.black87 : Colors.white,
                  size: baseFontSize * 1.5,
                ),
                selectedIconTheme: IconThemeData(
                  color: isLightMode ? Colors.black : Colors.white,
                  size: baseFontSize * 1.5,
                ),
                itemPadding: EdgeInsets.symmetric(
                  vertical: cardPadding * 0.5,
                  horizontal: cardPadding,
                ),
              ),
              extendedTheme: SidebarXTheme(
                width: 200,
                decoration: BoxDecoration(
                  gradient: appGradients.sidebarGradient,
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isLightMode ? Colors.black87 : Colors.white,
                  fontSize: baseFontSize * 0.9,
                ),
                selectedTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isLightMode ? Colors.black : Colors.white,
                  fontSize: baseFontSize * 0.9,
                ),
              ),
              items: [
                SidebarXItem(
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: appGradients.cardGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: avatarRadius * 0.6,
                      backgroundImage: NetworkImage(imageUrl),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                  label: userName,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SidebarXItem(
                  icon: Icons.fitness_center,
                  label: 'Workouts',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      if (FirebaseAuth.instance.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in to access Workouts')),
                        );
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } else {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Bodypartsscreen()));
                      }
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.restaurant_menu,
                  label: 'Nutrition',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => DietCardScreen()));
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => WeeklyChart()));
                    }
                    );
                  },
                ),
                SidebarXItem(
                  icon: Icons.notifications,
                  label: 'Notification',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => ALLNotification()));
                    }
                    );
                  },
                ),
                SidebarXItem(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      if (FirebaseAuth.instance.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in to edit profile')),
                        );
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } else {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => ProfileEditPage()));
                      }
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      _logout(context);
                    });
                  },
                ),
              ],
              footerBuilder: (context, extended) {
                final themeController = Get.find<ThemeController>();
                if (!extended) {
                  return Obx(() {
                    return IconButton(
                      icon: Icon(
                        themeController.isDark.value ? Icons.dark_mode : Icons.light_mode,
                        color: isLightMode ? Colors.black87 : Colors.white,
                      ),
                      onPressed: () =>
                          themeController.toggleTheme(!themeController.isDark.value),
                    );
                  });
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        themeController.isDark.value ? Icons.dark_mode : Icons.light_mode,
                        color: isLightMode ? Colors.black87 : Colors.white,
                      ),
                      const SizedBox(width: 1),
                      Expanded(
                        child: Text(
                          'Theme',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: isLightMode ? Colors.black87 : Colors.white,
                            fontSize: baseFontSize * 0.9,
                          ),
                        ),
                      ),
                      Obx(() => Expanded(
                        child: Switch(
                          value: themeController.isDark.value,
                          onChanged: (value) => themeController.toggleTheme(value),
                          activeColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Theme.of(context).dividerColor,
                        ),
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: Duration(milliseconds: 800),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: appGradients.cardGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundImage: NetworkImage(imageUrl),
                                  backgroundColor: Theme.of(context).cardColor,
                                ),
                              ),
                              SizedBox(width: cardPadding),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      greetingIcon,
                                      color: Theme.of(context).iconTheme.color,
                                      size: baseFontSize * 1.5,
                                    ),
                                    SizedBox(width: cardPadding * 0.5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$greeting, $userName",
                                            style: Theme.of(context).textTheme.titleLarge,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (userId.isNotEmpty)
                                            Text(
                                              "ID: $userId",
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: cardPadding * 0.5),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dateList.length,
                        itemBuilder: (context, index) {
                          final date = dateList[index];
                          final isToday = DateFormat('yyyy-MM-dd').format(date) == today;

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardPadding * 0.3),
                            child: Card(
                              elevation: 6,
                              shadowColor: Theme.of(context).shadowColor.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: isToday ? null : Theme.of(context).cardColor,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {},
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: isToday ? appGradients.cardGradient : null,
                                    borderRadius: BorderRadius.circular(20),
                                    border: isToday
                                        ? null
                                        : Border.all(color: Theme.of(context).dividerColor!, width: 1),
                                  ),
                                  padding: EdgeInsets.all(cardPadding * 0.5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('MMM').format(date),
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                          color: isToday
                                              ? (isLightMode ? Colors.black87 : Colors.white)
                                              : Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat('d').format(date),
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isToday
                                              ? (isLightMode ? Colors.black : Colors.white)
                                              : Theme.of(context).textTheme.bodyLarge!.color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat('EEE').format(date),
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isToday
                                              ? (isLightMode ? Colors.black54 : Colors.white70)
                                              : Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: cardPadding * 0.5),
                    Wrap(
                      spacing: cardPadding,
                      runSpacing: cardPadding,
                      alignment: WrapAlignment.center,
                      children: const [
                        WeeklyChart(),
                      ],
                    ),
                    SizedBox(height: cardPadding),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToStepsScreen(context),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 170,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(25),
                                gradient: appGradients.cardGradient,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Start running",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: isLightMode ? Colors.black87 : Colors.white,
                                      ),
                                    ),
                                    Image(
                                      image: AssetImage("assets/images/run.png"),
                                      width: 130,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _navigateToStepsScreen(context),
                            child: Container(
                              height: 170,
                              width: MediaQuery.of(context).size.width * 0.38,
                              decoration: BoxDecoration(
                                gradient: appGradients.cardGradient,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: FutureBuilder<Map<String, dynamic>?>(
                                future: _fetchTodaySteps(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError ||
                                      snapshot.data == null ||
                                      FirebaseAuth.instance.currentUser == null) {
                                    return Center(
                                      child: Text(
                                        'Sign In to View Steps',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          color: isLightMode ? Colors.black87 : Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  final data = snapshot.data!;
                                  final steps = data['steps'] ?? 0;
                                  final distance = data['distance']?.toStringAsFixed(2) ?? '0.00';
                                  final calories = data['calories']?.toStringAsFixed(1) ?? '0.0';
                                  const stepGoal = 10000;
                                  final percent = (steps / stepGoal).clamp(0.0, 1.0);

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          'STEPS',
                                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: isLightMode ? Colors.black87 : Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: CircularPercentIndicator(
                                            radius: 40.0,
                                            lineWidth: 8.0,
                                            percent: percent,
                                            center: Text(
                                              '$steps',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            progressColor: Theme.of(context).primaryColor,
                                            backgroundColor: Theme.of(context).dividerColor!,
                                            animation: true,
                                            animationDuration: 1000,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '$distance km',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: isLightMode ? Colors.black87 : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '$calories kcal',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: isLightMode ? Colors.black87 : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: cardPadding),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToBMICalculator(context),
                            child: Container(
                              height: 170,
                              width: MediaQuery.of(context).size.width * 0.30,
                              decoration: BoxDecoration(
                                gradient: appGradients.cardGradient,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "check bmi",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: isLightMode ? Colors.black87 : Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: BMIGauge(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to access Workouts')),
                                );
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()));
                              } else {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => Bodypartsscreen()));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 170,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor!,
                                    style: BorderStyle.solid,
                                    width: 3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(25),
                                gradient: appGradients.cardGradient,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Start Workout",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: isLightMode ? Colors.black87 : Colors.white,
                                      ),
                                    ),
                                    Image(
                                      image: AssetImage("assets/images/startw.png"),
                                      width: 130,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: cardPadding),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print('Tapped water tracker');
                                  if (FirebaseAuth.instance.currentUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please sign in to track water')),
                                    );
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => const LoginScreen()));
                                  } else {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => WaterPage()));
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context).dividerColor!,
                                        width: 3,
                                        strokeAlign: 1,
                                      ),
                                      left: BorderSide(
                                        color: Theme.of(context).dividerColor!,
                                        width: 3,
                                        strokeAlign: 1,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).shadowColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: FutureBuilder<Map<String, dynamic>>(
                                    future: _fetchWaterData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError ||
                                          snapshot.data == null ||
                                          FirebaseAuth.instance.currentUser == null) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Track Water",
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: isLightMode ? Colors.black87 : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Sign In to View',
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: isLightMode ? Colors.black87 : Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        );
                                      }
                                      final data = snapshot.data!;
                                      final todayIntakeMl = data['todayIntakeMl']?.toDouble() ?? 0.0;
                                      final dailyGoalMl = data['dailyGoalMl']?.toDouble() ?? 2000.0;
                                      final percent = (todayIntakeMl / dailyGoalMl).clamp(0.0, 1.0);

                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Track Water",
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: isLightMode ? Colors.black87 : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            CircularPercentIndicator(
                                              radius: 40.0,
                                              lineWidth: 8.0,
                                              percent: percent,
                                              center: Text(
                                                '${(percent * 100).toInt()}%',
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                              progressColor: Theme.of(context).primaryColor,
                                              backgroundColor: Theme.of(context).dividerColor!,
                                              animation: true,
                                              animationDuration: 1000,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${(todayIntakeMl / 1000).toStringAsFixed(2)} L / ${(dailyGoalMl / 1000).toStringAsFixed(2)} L',
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: isLightMode ? Colors.black87 : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        print('Tapped sleep tracker');
                                        if (FirebaseAuth.instance.currentUser == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please sign in to track sleep')),
                                          );
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => const LoginScreen()));
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => SleepTracker()));
                                        }
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.40,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).dividerColor!,
                                              width: 3,
                                              strokeAlign: 1,
                                            ),
                                            left: BorderSide(
                                              color: Theme.of(context).dividerColor!,
                                              width: 3,
                                              strokeAlign: 1,
                                            ),
                                          ),
                                          gradient: appGradients.cardGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).shadowColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image(
                                            image: AssetImage("assets/images/slepi.png"),
                                            height: 80,
                                            width: MediaQuery.of(context).size.width * 0.40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FadeIn(
                                      duration: const Duration(milliseconds: 1000),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (FirebaseAuth.instance.currentUser == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please sign in to track sleep')),
                                            );
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                          } else {
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => SleepTracker()));
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.40,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            gradient: appGradients.cardGradient,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context).shadowColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: FutureBuilder<Map<String, dynamic>?>(
                                            future: SleepService().getSleepData(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                );
                                              }
                                              if (snapshot.hasError || snapshot.data == null || FirebaseAuth.instance.currentUser == null) {
                                                return Center(
                                                  child: Text(
                                                    'Sign In to View Sleep',
                                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                      color: isLightMode ? Colors.black87 : Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              }

                                              final data = snapshot.data!;
                                              final sleepHours = data['sleepHours']?.toDouble() ?? 0.0;
                                              final sleepGoal = data['sleepGoal']?.toDouble() ?? 8.0;
                                              final percent = (sleepHours / sleepGoal).clamp(0.0, 1.0);

                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min, // 👈 fix bottom overflow
                                                  children: [
                                                    Text(
                                                      "Sleep",
                                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                        color: isLightMode ? Colors.black87 : Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      height: 20,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: FractionallySizedBox(
                                                        alignment: Alignment.centerLeft,
                                                        widthFactor: percent,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12), // slightly bigger radius
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight, // diagonal gradient
                                                              colors: [
                                                                Theme.of(context).primaryColor,
                                                                Theme.of(context).primaryColor.withOpacity(0.7),
                                                              ],
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Theme.of(context).primaryColor.withOpacity(0.4),
                                                                blurRadius: 10,
                                                                spreadRadius: 1,
                                                                offset: const Offset(0, 4), // soft drop shadow
                                                              ),
                                                            ],
                                                            border: Border.all(
                                                              color: Colors.white.withOpacity(0.3), // subtle border/glow effect
                                                              width: 1.0,
                                                            ),
                                                          ),

                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "${sleepHours.toStringAsFixed(1)}h / ${sleepGoal.toStringAsFixed(1)}h",
                                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                        color: isLightMode ? Colors.black87 : Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // ✅ Food Recognition Container

                          // ✅ Chatbot Container
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatScreen()), // 👈 ChatScreen ka route
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height * 0.23,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.orangeAccent.withOpacity(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: Offset(2, 0),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image(
                                        image: AssetImage("assets/images/robot.png"),
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      "AI Chatbot",
                                      style: GoogleFonts.bebasNeue(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double cardPadding;
  final double fontSize;

  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.cardPadding,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Icon(icon, size: fontSize * 1.5, color: Theme.of(context).iconTheme.color),
            SizedBox(height: cardPadding * 0.5),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isLightMode ? Colors.black87 : Colors.white,
              ),
            ),
            SizedBox(height: cardPadding * 0.25),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isLightMode ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double radius;
  final double fontSize;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.radius,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return AnimatedScaleButton(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor!.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: radius * 0.8,
              ),
            ),
          ),
          SizedBox(height: radius * 0.2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: isLightMode ? Colors.black87 : Colors.white,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class GoalRing extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final double radius;

  const GoalRing({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: radius * 0.2,
          percent: percent,
          center: Text(
            "${(percent * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black87 : Colors.white,
            ),
          ),
          progressColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).dividerColor!,
        ),
        SizedBox(height: radius * 0.2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: isLightMode ? Colors.black87 : Colors.white,
          ),
        ),
      ],
    );
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedScaleButton({super.key, required this.child, required this.onTap});

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: widget.child,
      ),
    );
  }
}