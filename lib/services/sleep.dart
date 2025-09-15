import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepService {
  final CollectionReference _sleepCollection =
  FirebaseFirestore.instance.collection("sleep_data");

  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection("users");

  /// ✅ Helper: get current userId from `users` collection
  Future<String?> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await _usersCollection.doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.id; // users collection ka docId ko userId maana
    }
    return null;
  }

  /// Save sleep data with userId automatically
  Future<void> saveSleepData({
    required double sleepHours,
    required double sleepGoal,
    required double motionAverage,
  }) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception("⚠️ User not found in Firestore");

    final now = DateTime.now();
    final docId = "${userId}_${now.year}_${now.month}_${now.day}";

    await _sleepCollection.doc(docId).set({
      "userId": userId,
      "sleepHours": sleepHours,
      "sleepGoal": sleepGoal,
      "motionAverage": motionAverage,
      "date": Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  /// Fetch today’s sleep data for current user
  Future<Map<String, dynamic>?> getSleepData() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return null;

    final now = DateTime.now();
    final docId = "${userId}_${now.year}_${now.month}_${now.day}";

    final doc = await _sleepCollection.doc(docId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  /// Fetch last N days of sleep data for current user
  Future<List<Map<String, dynamic>>> getLastDays(int days) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));

    final query = await _sleepCollection
        .where("userId", isEqualTo: userId)
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy("date", descending: true)
        .get();

    return query.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
