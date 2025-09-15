import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch existing user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to edit your profile.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _nameController.text = data?['name']?.toString() ?? '';
          _emailController.text = data?['email']?.toString() ?? user.email ?? '';
          _existingImageUrl = data?['imageUrl']?.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _emailController.text = user.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    }
  }

  // Pick Image
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload to Cloudinary
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = "dpfebhnli";
    const uploadPreset = "ml_default";

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'];
    } else {
      debugPrint("Cloudinary upload failed: ${response.statusCode}");
      return null;
    }
  }

  // Validate email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Save to Firestore
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to save your profile.")),
      );
      return;
    }

    if (_emailController.text.isNotEmpty && !_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl = _existingImageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImageToCloudinary(_imageFile!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image. Saving other details.")),
        );
      }
    }

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "userId": user.uid,
        "name": _nameController.text,
        "email": _emailController.text,
        "imageUrl": imageUrl ?? "",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isLoading = false;
        _existingImageUrl = imageUrl; // Update existing image URL after save
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? NetworkImage(_existingImageUrl!)
                    : null,
                child: _imageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty)
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}