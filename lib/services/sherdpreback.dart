import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const String _introDoneKey = "intro_done";
  static const String _onboardingDoneKey = "onboarding_done";
  static const String _isLoggedInKey = "is_logged_in";

  // Intro
  static Future<void> setIntroDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introDoneKey, true);
  }

  static Future<bool> isIntroDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introDoneKey) ?? false;
  }

  // Onboarding flow after login
  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDoneKey, true);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  // Login
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}
