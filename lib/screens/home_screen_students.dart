import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_list.dart';
import 'dart:io';

class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentCanteenList();
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
  String _language = 'en'; // 默认语言为英语

  // 语言代码和对应的显示名称
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'zh': '中文',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String currentUsername = prefs.getString('currentUsername') ?? '';
    _language = prefs.getString('language_$currentUsername') ?? 'en';
    List<String>? users = prefs.getStringList('users');
    String currentUserPreference = prefs.getString('dietary_$currentUsername') ?? 'No Preference';

    if (users != null) {
      List<Map<String, dynamic>> matchingUsers = [];
      
      for (String userData in users) {
        List<String> userInfo = userData.split('|');
        if (userInfo.length >= 2 && userInfo[0] != currentUsername) {
          String username = userInfo[0];
          String nickname = prefs.getString('nickname_$username') ?? username;
          String? avatarPath = userInfo.length > 3 ? userInfo[3] : null;
          String userPreference = prefs.getString('dietary_$username') ?? 'No Preference';
          
          if (userPreference == currentUserPreference && userPreference != 'No Preference') {
            matchingUsers.add({
              'username': username,
              'nickname': nickname,
              'avatarPath': avatarPath,
              'preference': userPreference,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loading,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_matchingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMatchingUsers,
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
                Chip(
                  label: Text(user['preference']),
                  backgroundColor: const Color(0xFF16a951).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF16a951)),
                ),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.viewProfile(user['nickname']),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String nickname = '';
  String dietaryPreference = 'No Preference';
  String language = 'en';
  File? _avatarImage;
  final List<String> dietaryOptions = [
    'No Preference',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
    'Nut Allergy',
    'Lactose Intolerant',
    'Pescatarian'
  ];

  // 语言选项
  final Map<String, String> languageOptions = {
    'en': 'English',
    'zh': '中文',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('currentUsername') ?? 'No Username';
      nickname = prefs.getString('nickname_$username') ?? username;
      dietaryPreference = prefs.getString('dietary_$username') ?? 'No Preference';
      language = prefs.getString('language_$username') ?? 'en';
      String? avatarPath = prefs.getString('currentUserAvatar');
      if (avatarPath != null && avatarPath.isNotEmpty) {
        _avatarImage = File(avatarPath);
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
      
      // 保存头像路径
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserAvatar', image.path);
      
      // 更新用户列表中的头像路径
      List<String>? users = prefs.getStringList('users');
      if (users != null) {
        for (int i = 0; i < users.length; i++) {
          List<String> userData = users[i].split('|');
          if (userData[0] == username) {
            if (userData.length > 3) {
              userData[3] = image.path;
            } else {
              userData.add(image.path);
            }
            users[i] = userData.join('|');
            break;
          }
        }
        await prefs.setStringList('users', users);
      }
    }
  }

  Future<void> _saveNickname(String newNickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname_$username', newNickname);
    setState(() {
      nickname = newNickname;
    });
  }

  Future<void> _saveDietaryPreference(String preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dietary_$username', preference);
    setState(() {
      dietaryPreference = preference;
    });
  }

  Future<void> _saveLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_$username', newLanguage);
    setState(() {
      language = newLanguage;
    });
    
    // 通知应用程序更改语言
    if (mounted) {
      final ByteBitesAppState? appState = context.findAncestorStateOfType<ByteBitesAppState>();
      if (appState != null) {
        appState.changeLanguage(Locale(newLanguage));
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.languageChanged(
              languageOptions[newLanguage] ?? newLanguage,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child: _avatarImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16a951),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            nickname,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '@$username',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          _buildEditableField(
            label: AppLocalizations.of(context)!.nickname,
            value: nickname,
            onSave: _saveNickname,
          ),
          const SizedBox(height: 20),
          _buildDietaryPreferenceSelector(),
          const SizedBox(height: 20),
          _buildLanguageSelector(),
          const SizedBox(height: 30),
          _buildDietaryBadge(),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label updated')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dietaryPreference,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: dietaryPreference,
          items: dietaryOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _saveDietaryPreference(newValue);
            }
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.language,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: language,
          items: languageOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _saveLanguage(newValue);
            }
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryBadge() {
    if (dietaryPreference == 'No Preference') {
      return Container();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.green[800]),
          const SizedBox(width: 8),
          Text(
            dietaryPreference,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenStudent extends StatefulWidget {
  const HomeScreenStudent({super.key});

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
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
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: const Color(0xFF16a951),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF16a951),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant),
            label: AppLocalizations.of(context)!.canteen,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: AppLocalizations.of(context)!.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}
