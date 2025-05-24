import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回上一页
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Register',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF176158)),
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                void _register() async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('username', usernameController.text);
                  await prefs.setString('password', passwordController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration successful!')),
                  );

                  Navigator.pushReplacementNamed(context, '/login');
                }
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
