import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';
import 'exercise.dart';

class ExerciseApi {
  static const String baseUrl = "https://exercisedb-api.vercel.app/api/v1";

  /// Get exercises by body part (e.g. chest, cardio, back) with pagination
  static Future<List<Exercise>> fetchByBodyPart(String bodyPart, {int offset = 0, int limit = 100}) async {
    final url = "$baseUrl/bodyparts/$bodyPart/exercises?offset=$offset&limit=$limit";
    try {
      final response = await http.get(Uri.parse(url));
      print("API Request URL: $url"); // Log URL for debugging
      print("API Response Status: ${response.statusCode}"); // Log status code
      print("API Response Body: ${response.body}"); // Log raw response for debugging

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> exerciseList;

        // Check if the response is a map with an "exercises" or "data" key
        if (data is Map && data.containsKey("exercises")) {
          exerciseList = data["exercises"] as List<dynamic>;
        } else if (data is Map && data.containsKey("data")) {
          exerciseList = data["data"] as List<dynamic>;
        } else if (data is List) {
          exerciseList = data;
        } else {
          throw Exception("Unexpected API response format: $data");
        }

        return exerciseList.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Failed to load exercises: HTTP ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error fetching exercises for $bodyPart: $e");
      throw Exception("Error fetching exercises: $e");
    }
  }

  /// Get exercises by target muscle (e.g. abs, biceps, triceps)
  static Future<List<Exercise>> fetchByTarget(String target) async {
    final url = "$baseUrl/exercises/target/$target";
    try {
      final response = await http.get(Uri.parse(url));
      print("API Request URL: $url");
      print("API Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Exercise.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load exercises: HTTP ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error fetching exercises for target $target: $e");
      throw Exception("Error fetching exercises: $e");
    }
  }

  /// Get all exercises with pagination
  static Future<List<Exercise>> fetchAll({int offset = 0, int limit = 50}) async {
    final url = "$baseUrl/exercises?offset=$offset&limit=$limit";
    try {
      final response = await http.get(Uri.parse(url));
      print("API Request URL: $url");
      print("API Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Exercise.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load exercises: HTTP ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error fetching all exercises: $e");
      throw Exception("Error fetching exercises: $e");
    }
  }
}