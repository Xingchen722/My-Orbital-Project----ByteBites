import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 这里是首页（餐厅列表页）示例
class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Canteen Page', style: TextStyle(fontSize: 24)));
  }
}

// 这里是用户资料页示例
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page', style: TextStyle(fontSize: 24)));
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Map<String, dynamic>> _matchingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchingUsers();
  }

  Future<void> _loadMatchingUsers() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String currentUsername = prefs.getString('currentUsername') ?? '';
    List<String>? users = prefs.getStringList('users');
    List<String> currentUserPreferences = prefs.getStringList('preferences_$currentUsername') ?? [];

    if (users != null) {
      List<Map<String, dynamic>> matchingUsers = [];
      
      for (String userData in users) {
        List<String> userInfo = userData.split('|');
        if (userInfo.length >= 2 && userInfo[0] != currentUsername) {
          String username = userInfo[0];
          String nickname = prefs.getString('nickname_$username') ?? username;
          String? avatarPath = userInfo.length > 3 ? userInfo[3] : null;
          
          List<String> userPreferences = prefs.getStringList('preferences_$username') ?? [];
          
          // 计算共同偏好
          List<String> commonPreferences = currentUserPreferences
              .where((pref) => userPreferences.contains(pref))
              .toList();
          
          if (commonPreferences.isNotEmpty) {
            matchingUsers.add({
              'username': username,
              'nickname': nickname,
              'avatarPath': avatarPath,
              'commonPreferences': commonPreferences,
            });
          }
        }
      }
      
      setState(() {
        _matchingUsers = matchingUsers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matchingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '没有找到匹配的用户',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matchingUsers.length,
      itemBuilder: (context, index) {
        final user = _matchingUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: user['avatarPath'] != null
                  ? FileImage(File(user['avatarPath']))
                  : null,
              child: user['avatarPath'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              user['nickname'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${user['username']}'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: (user['commonPreferences'] as List<String>).map((pref) {
                    return Chip(
                      label: Text(pref),
                      backgroundColor: Colors.blue[100],
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    );
                  }).toList(),
                ),
              ],
            ),
            onTap: () {
              // TODO: 实现查看用户详情页面的功能
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('查看 ${user['nickname']} 的主页')),
              );
            },
          ),
        );
      },
    );
  }
}

// 主页面，带底部导航栏
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CanteenPage(),
    const ExplorePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByteBites'),
        backgroundColor: Colors.blue[700],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Canteen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
