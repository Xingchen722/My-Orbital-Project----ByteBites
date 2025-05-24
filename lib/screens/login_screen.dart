import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveCredentials(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('password', password);
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    String savedUser = prefs.getString('username') ?? '';
    String savedPass = prefs.getString('password') ?? '';

    if (_usernameController.text == savedUser && _passwordController.text == savedPass) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
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
            child: Column(
              children: [
                Image.asset('assets/hum.png', height: 58), // 头像图片
                SizedBox(height: 20),
                Text('ByteBites', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF176158))),
                SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: Color(0xFFd4E4EF)),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color(0xFFd4E4EF)),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Image.asset('assets/spongebob.png', height: 48),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF16a951)),
                        child: Text('Login'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF16a951)),
                        child: Text('Signup'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Image.asset('assets/crab.png', height: 48),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
