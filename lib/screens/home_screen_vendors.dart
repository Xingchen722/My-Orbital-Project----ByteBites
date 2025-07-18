import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/screens/vendor/vendor_menu_page.dart';
import 'package:flutter_application_1/screens/vendor/vendor_reviews_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VendorCanteenPage extends StatelessWidget {
  const VendorCanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Vendor Dashboard', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text(
            'Manage your canteen and orders',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  String username = '';
  String nickname = '';
  String canteenName = '';
  String canteenDescription = '';
  String canteenHours = '';
  String canteenAddress = '';
  String canteenId = '';
  File? _avatarImage;

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
      canteenName = prefs.getString('canteen_$username') ?? 'No Canteen Name';
      canteenDescription = prefs.getString('canteen_desc_$username') ?? '';
      canteenHours = prefs.getString('canteen_hours_$username') ?? '';
      canteenAddress = prefs.getString('canteen_addr_$username') ?? '';
      canteenId = prefs.getString('canteenId_$username') ?? '';
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

  Future<void> _saveCanteenName(String newCanteenName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_$username', newCanteenName);
    setState(() {
      canteenName = newCanteenName;
    });
  }

  Future<void> _saveCanteenDescription(String desc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_desc_$username', desc);
    setState(() {
      canteenDescription = desc;
    });
  }

  Future<void> _saveCanteenHours(String hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_hours_$username', hours);
    setState(() {
      canteenHours = hours;
    });
  }

  Future<void> _saveCanteenAddress(String addr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_addr_$username', addr);
    setState(() {
      canteenAddress = addr;
    });
  }

  Future<void> _saveCanteenId(String newId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteenId_$username', newId);
    // 自动同步Canteen Name
    final canteenNameFromList = _getCanteenNameById(newId);
    if (canteenNameFromList != null) {
      await prefs.setString('canteen_$username', canteenNameFromList);
      setState(() {
        canteenName = canteenNameFromList;
      });
    }
    setState(() {
      canteenId = newId;
    });
  }

  String? _getCanteenNameById(String id) {
    // 可根据实际项目将此处的餐厅列表替换为全局常量或配置
    const canteenList = [
      {'id': '1', 'name': 'The Summit'},
      {'id': '2', 'name': 'Frontier'},
      {'id': '3', 'name': 'Techno Edge'},
      {'id': '4', 'name': 'PGP'},
      {'id': '5', 'name': 'The Deck'},
      {'id': '6', 'name': 'The Terrace'},
      {'id': '7', 'name': 'Yusof Ishak House'},
      {'id': '8', 'name': 'Fine Food'},
    ];
    final match = canteenList.firstWhere(
      (c) => c['id'] == id,
      orElse: () => {},
    );
    return match['name'] as String?;
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
                      color: Colors.blue,
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
            label: 'Nickname',
            value: nickname,
            onSave: _saveNickname,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Canteen Name',
            value: canteenName,
            onSave: _saveCanteenName,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Description',
            value: canteenDescription,
            onSave: _saveCanteenDescription,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Opening Hours',
            value: canteenHours,
            onSave: _saveCanteenHours,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Address',
            value: canteenAddress,
            onSave: _saveCanteenAddress,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Canteen ID',
            value: canteenId,
            onSave: _saveCanteenId,
          ),
          // 退出登录按钮
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentUsername');
              await prefs.remove('currentUserType');
              await prefs.remove('currentUserAvatar');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(AppLocalizations.of(context)!.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
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
}

class HomeScreenVendor extends StatefulWidget {
  const HomeScreenVendor({super.key});

  @override
  State<HomeScreenVendor> createState() => _HomeScreenVendorState();
}

class _HomeScreenVendorState extends State<HomeScreenVendor> {
  int _selectedIndex = 0;

  late String canteenId;
  bool _canteenIdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCanteenId();
  }

  void _loadCanteenId() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? '';
    setState(() {
      canteenId = prefs.getString('canteenId_$username') ?? '1';
      _canteenIdLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_canteenIdLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Widget> _pages = [
      VendorCanteenPage(),
      VendorMenuPage(canteenId: canteenId),
      VendorReviewsPage(canteenId: canteenId),
      VendorProfilePage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('ByteBites - Vendor'),
        backgroundColor: Colors.blue[700],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
