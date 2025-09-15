import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterService {
  final String apiKey = dotenv.env['API_KEY'] ?? "";

  /// Chatbot (unchanged)
  Future<String> chatWithCoach(String userInput) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");
    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a friendly fitness and diet coach. Answer clearly and helpfully."
            },
            {"role": "user", "content": userInput}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["choices"] != null &&
            data["choices"].isNotEmpty &&
            data["choices"][0]["message"] != null) {
          return data["choices"][0]["message"]["content"] ?? "⚠️ Empty response";
        } else {
          return "⚠️ No reply from AI.";
        }
      } else {
        throw Exception(
            "Chat failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      return "Sorry, something went wrong while contacting the coach.";
    }
  }

  /// Food recognition (unchanged)
  Future<String> recognizeFood(String base64Image) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a friendly AI that identifies food items and estimates calories from images."
            },
            {"role": "user", "content": "Identify this food and estimate calories."},
            {
              "role": "user",
              "content": {"type": "image_data", "image_data": base64Image}
            }
          ]
        }),
      );

      print("🔹 HTTP Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["choices"] != null &&
            data["choices"].isNotEmpty &&
            data["choices"][0]["message"] != null) {
          return data["choices"][0]["message"]["content"] ?? "⚠️ Empty response";
        } else {
          return "⚠️ No recognition result.";
        }
      } else {
        return "API Error [${response.statusCode}]: ${response.body}";
      }
    } catch (e, st) {
      print("❌ Exception: $e");
      print("❌ Stacktrace: $st");
      return "Exception occurred: $e";
    }
  }

  /// ✅ New: AI Workout Coach
  Future<List<Map<String, dynamic>>> generateWorkout({
    required String fitnessLevel,
    required String targetMuscle,
    required String equipment,
  }) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final prompt = """
You are a professional fitness coach. 
Create a 30-minute workout for a $fitnessLevel user targeting $targetMuscle muscles using $equipment.
Return ONLY a JSON array (no extra text) with fields: exercise, sets, reps, rest_seconds.
Example:
[
  {"exercise": "Push-ups", "sets": 3, "reps": 12, "rest_seconds": 60},
  {"exercise": "Squats", "sets": 3, "reps": 15, "rest_seconds": 60}
]
""";

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o",
          "messages": [
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["choices"]?[0]?["message"]?["content"];

        print("🔹 AI Raw Response: $message");

        if (message != null) {
          // Extract JSON array safely
          final jsonStart = message.indexOf("[");
          final jsonEnd = message.lastIndexOf("]");
          if (jsonStart != -1 && jsonEnd != -1) {
            final jsonString = message.substring(jsonStart, jsonEnd + 1);
            try {
              return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
            } catch (e) {
              print("❌ JSON parse error: $e");
              return [];
            }
          }
        }
      } else {
        print("❌ API Error [${response.statusCode}]: ${response.body}");
      }
      return [];
    } catch (e, st) {
      print("❌ Workout AI exception: $e");
      print("❌ Stacktrace: $st");
      return [];
    }
  }
}
