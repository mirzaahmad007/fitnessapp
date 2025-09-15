import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/openrouter.dart';
import '../services/aiservice.dart';
import '../services/openrouter_service.dart';
import '../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final OpenRouterService api = OpenRouterService();
  final FirestoreService firestore = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";

  /// 🔹 Send message
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    _controller.clear();

    // ✅ Save user message to Firestore
    await firestore.saveChatMessage(userId, "user", text);

    // ✅ Get AI reply
    final reply = await api.chatWithCoach(text);

    // ✅ Save bot reply to Firestore
    await firestore.saveChatMessage(userId, "bot", reply);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat with Coach",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            /// 🔹 Real-time Firestore messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.fetchChatMessages(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No messages yet",
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true, // latest messages at bottom
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index].data() as Map<String, dynamic>;
                      final isUser = msg["role"] == "user";

                      return Align(
                        alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) // Bot avatar
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                    AssetImage('assets/images/robot.png'),
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.blueAccent.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20).copyWith(
                                      bottomRight: isUser
                                          ? Radius.circular(4)
                                          : Radius.circular(20),
                                      bottomLeft: isUser
                                          ? Radius.circular(20)
                                          : Radius.circular(4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    msg["text"] ?? "",
                                    style: GoogleFonts.poppins(
                                      color: isUser
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser) // User avatar
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: FutureBuilder<String?>(
                                    future: firestore.fetchUserImage(userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircleAvatar(
                                          radius: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        );
                                      }
                                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                                        return CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(snapshot.data!),
                                        );
                                      } else {
                                        return CircleAvatar(
                                          radius: 20,
                                          child: Icon(Icons.person, color: Colors.grey[600]),
                                        );
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            if (_loading)
              Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  strokeWidth: 3,
                ),
              ),

            /// 🔹 Message input
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Ask your coach...",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
