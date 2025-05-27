import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'register_screen.dart';
import 'home_screen_students.dart';
import 'home_screen_vendors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  File? _userAvatar;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');

    if (users == null || users.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No users registered yet')));
      return;
    }

    bool loginSuccess = false;
    String userType = 'student';
    String? avatarPath;

    for (String user in users) {
      List<String> userData = user.split('|');
      if (userData.length >= 3 &&
          userData[0] == _usernameController.text &&
          userData[1] == _passwordController.text) {
        loginSuccess = true;
        userType = userData[2];
        if (userData.length > 3 && userData[3].isNotEmpty) {
          avatarPath = userData[3];
        }
        break;
      }
    }

    if (loginSuccess) {
      // Store current user's info separately for easy access
      await prefs.setString('currentUsername', _usernameController.text);
      await prefs.setString('currentUserType', userType);
      if (avatarPath != null) {
        await prefs.setString('currentUserAvatar', avatarPath);
      }

      if (userType == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreenStudent()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreenVendor()),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              // Wrap your form with Form widget
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'ByteBites',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_userAvatar != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(_userAvatar!),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    // Changed from TextField to TextFormField
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      // Add validation
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    // Changed from TextField to TextFormField
                    controller: _passwordController,
                    style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    obscureText: true,
                    validator: (value) {
                      // Add validation
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Image.asset('assets/spongebob.png', height: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16a951),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16a951),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset('assets/crab.png', height: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
