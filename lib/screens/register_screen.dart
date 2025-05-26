import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String userType = 'student';

  // Helper function to check if username exists
  Future<bool> isUsernameAvailable(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');
    if (users == null) return true;

    for (String user in users) {
      List<String> userData = user.split('|');
      if (userData.isNotEmpty && userData[0] == username) {
        return false;
      }
    }
    return true;
  }

  // New method to save credentials in list format
  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('users') ?? [];

    // Format: username|password|userType
    String newUser =
        '${usernameController.text}|${passwordController.text}|$userType';
    users.add(newUser);

    await prefs.setStringList('users', users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Register',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF176158),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter Username',
                hintStyle: TextStyle(color: Color(0xFFd4E4EF)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter Password',
                hintStyle: TextStyle(color: Color(0xFFd4E4EF)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: TextStyle(color: Color(0xFFd4E4EF)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are registering as a:',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Student User'),
                  selected: userType == 'student',
                  onSelected: (selected) {
                    setState(() {
                      userType = 'student';
                    });
                  },
                ),
                const SizedBox(width: 20),
                ChoiceChip(
                  label: const Text('Vendor User'),
                  selected: userType == 'vendor',
                  onSelected: (selected) {
                    setState(() {
                      userType = 'vendor';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Validate passwords match
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match!')),
                  );
                  return;
                }

                // Check username availability
                if (!await isUsernameAvailable(usernameController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username already exists!')),
                  );
                  return;
                }

                // Save credentials in new format
                await saveCredentials();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered Successfully')),
                );

                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16a951),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
