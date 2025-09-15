import 'package:fitnessapp/userscreens/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../onboardingwrapper/onboardingflow.dart';
import '../homescreen/homepage.dart';
import 'forgotpassword.dart'; // Import the Forgotpassword screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoginScreen = true;
  bool isPasswordVisible = false;
  LinearGradient backgroundGradient = const LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topLeft,
    colors: [Color(0xff300C0C), Color(0xff291D1D)],
  );
  String passwordStrengthEmoji = '';

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePasswordStrength);
  }

  void _validatePasswordStrength() {
    final password = passwordController.text;
    setState(() {
      if (password.isEmpty) {
        backgroundGradient = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topLeft,
          colors: [Color(0xff300C0C), Color(0xff291D1D)],
        );
        passwordStrengthEmoji = '';
      } else {
        bool isStrong = password.length >= 8 &&
            RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                .hasMatch(password);
        backgroundGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topLeft,
          colors: isStrong
              ? [Colors.green[200]!, Colors.green[400]!]
              : [Colors.red[200]!, Colors.red[400]!],
        );
        passwordStrengthEmoji = isStrong ? '😊 Strong' : '😔 Weak';
      }
    });
  }

  Future<void> _validateAndSubmit() async {
    List<String> emptyFields = [];
    if (isLoginScreen) {
      if (emailController.text.isEmpty) emptyFields.add('Email');
      if (passwordController.text.isEmpty) emptyFields.add('Password');
    } else {
      if (nameController.text.isEmpty) emptyFields.add('Name');
      if (emailController.text.isEmpty) emptyFields.add('Email');
      if (phoneController.text.isEmpty) emptyFields.add('Phone');
      if (passwordController.text.isEmpty) emptyFields.add('Password');
      if (confirmPasswordController.text.isEmpty) emptyFields.add('Confirm Password');
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    if (emptyFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${emptyFields.join(', ')} required')),
      );
      return;
    }

    try {
      if (isLoginScreen) {
        // 🔹 LOGIN
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final prefs = await SharedPreferences.getInstance();
        bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;

        // 🔹 Save login state
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          if (isFirstLogin) {
            await prefs.setBool('isFirstLogin', false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingFlow()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FitnessHomePage()),
            );
          }
        }
      } else {
        // 🔹 SIGNUP
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (mounted) {
          setState(() {
            isLoginScreen = true;
            emailController.clear();
            passwordController.clear();
            nameController.clear();
            phoneController.clear();
            confirmPasswordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful! Please log in.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email is already registered.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'user-not-found':
        case 'wrong-password':
          message = 'Invalid email or password.';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(gradient: backgroundGradient),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoginScreen ? "Login Your\nAccount" : "Create Your\nAccount",
                    style: GoogleFonts.alfaSlabOne(fontSize: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLoginScreen
                        ? "Sign in with the following methods"
                        : "Sign up with the following methods",
                    style: GoogleFonts.almendra(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  // Toggle Buttons
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (!isLoginScreen) {
                                setState(() {
                                  isLoginScreen = true;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoginScreen
                                  ? Colors.lightGreenAccent
                                  : Colors.white.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Login",
                              style: GoogleFonts.aclonica(
                                fontSize: 16,
                                color: isLoginScreen ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isLoginScreen) {
                                setState(() {
                                  isLoginScreen = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoginScreen
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.lightGreenAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.aclonica(
                                fontSize: 16,
                                color: isLoginScreen ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!isLoginScreen) ...[
                    _buildTextField(nameController, "Name", Icons.person),
                    const SizedBox(height: 15),
                  ],

                  _buildTextField(emailController, "Email", Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      }),
                  const SizedBox(height: 15),

                  if (!isLoginScreen) ...[
                    _buildTextField(phoneController, "Phone", Icons.phone,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),
                  ],

                  _buildPasswordField(passwordController, "Password"),
                  if (passwordStrengthEmoji.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(passwordStrengthEmoji,
                        style: GoogleFonts.almendra(fontSize: 16, color: Colors.white)),
                  ],

                  if (!isLoginScreen) ...[
                    const SizedBox(height: 15),
                    _buildPasswordField(confirmPasswordController, "Confirm Password"),
                  ],

                  // Forgot Password Link (above Login button, left-aligned)
                  if (isLoginScreen) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Forgotpassword()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.almendra(
                            fontSize: 14,
                            color: Colors.lightGreenAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isLoginScreen ? "Login" : "Sign Up",
                      style: GoogleFonts.aclonica(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon: IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white),
          onPressed: () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          },
        ),
      ),
    );
  }
}