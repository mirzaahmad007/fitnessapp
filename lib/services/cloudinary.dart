import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String _cloudinaryUploadUrl = "https://api.cloudinary.com/v1_1/dpfebhnli/image/upload";
  final String _cloudinaryPreset = "ml_default";

  /// Upload image to Cloudinary and get URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest("POST", Uri.parse(_cloudinaryUploadUrl));
      request.fields["upload_preset"] = _cloudinaryPreset;
      request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData.body);
        return data["secure_url"]; // ✅ Cloudinary image URL
      } else {
        print("Cloudinary Error: ${responseData.body}");
        return null;
      }
    } catch (e) {
      print("Upload Exception: $e");
      return null;
    }
  }
}
