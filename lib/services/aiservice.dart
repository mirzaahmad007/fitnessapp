import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Save a chat message
  Future<void> saveChatMessage(String userId, String role, String text) async {
    await _db.collection("chat_history").add({
      "userId": userId,
      "role": role, // "user" or "bot"
      "text": text,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Fetch chat history (real-time stream)
  Stream<QuerySnapshot> fetchChatMessages(String userId) {
    return _db
        .collection("chat_history")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  /// ✅ Save food recognition result
  Future<void> saveFood(String userId, String result, String imageUrl) async {
    await _db.collection("food_recognition").add({
      "userId": userId,
      "result": result,
      "imageUrl": imageUrl,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Fetch food recognition history
  Stream<QuerySnapshot> fetchFoodHistory(String userId) {
    return _db
        .collection("food_recognition")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  /// ✅ Fetch only user's profile imageUrl
  Future<String?> fetchUserImage(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!["imageUrl"] as String?;
    }
    return null;
  }
}
