import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/screens/vendor/vendor_menu_page.dart';
import 'package:flutter_application_1/screens/vendor/vendor_reviews_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert'; // Added for jsonDecode

class VendorCanteenPage extends StatefulWidget {
  const VendorCanteenPage({super.key});

  @override
  State<VendorCanteenPage> createState() => _VendorCanteenPageState();
}

class _VendorCanteenPageState extends State<VendorCanteenPage> {
  int todayOrderCount = 0;
  double totalSales = 0;
  int pendingOrderCount = 0;
  List<Map<String, dynamic>> recentReviews = [];
  String canteenId = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? '';
    canteenId = prefs.getString('canteenId_$username') ?? '1';
    // 评价数据
    final reviewKey = 'canteen_reviews_$canteenId';
    List<String> reviewStrings = prefs.getStringList(reviewKey) ?? [];
    final now = DateTime.now();
    int todayCount = 0;
    int pendingCount = 0;
    double sales = 0;
    List<Map<String, dynamic>> reviews = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
    reviews.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
    for (var r in reviews) {
      final createdAt = DateTime.tryParse(r['createdAt'] ?? '') ?? now;
      if (createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day) {
        todayCount++;
      }
      if ((r['reply'] ?? '').toString().isEmpty) {
        pendingCount++;
      }
      // 估算销售额：评价中有 price 字段
      if (r['price'] != null) {
        sales += double.tryParse(r['price'].toString()) ?? 0;
      }
    }
    setState(() {
      todayOrderCount = todayCount;
      totalSales = sales;
      pendingOrderCount = pendingCount;
      recentReviews = reviews.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计卡片
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Reviews', todayOrderCount.toString(), Colors.green, subtitle: 'Today'),
              _buildStatCard('Total Sales', 'S\$${totalSales.toStringAsFixed(2)}', Colors.orange),
              _buildStatCard('Pending', pendingOrderCount.toString(), Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          // 快捷入口
          Text('Quick Access', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(context, Icons.restaurant_menu, 'Menu', 1),
              _buildQuickButton(context, Icons.rate_review, 'Reviews', 2),
              _buildQuickButton(context, Icons.analytics, 'Data', null),
            ],
          ),
          const SizedBox(height: 24),
          // 近期评价摘要
          Text('Recent Reviews', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...recentReviews.isEmpty
              ? [Text('No Reviews Yet', style: const TextStyle(color: Colors.grey))]
              : recentReviews.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(r['comment'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: ${r['rating'] ?? ''}'),
                        if (r['reply'] != null && r['reply'].toString().isNotEmpty)
                          Text('Vendor Reply: ${r['reply']}', style: const TextStyle(color: Colors.green)),
                        if (r['createdAt'] != null)
                          Text(_formatTime(r['createdAt'], AppLocalizations.of(context)!)),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, {String? subtitle}) {
    return Card(
      color: color.withOpacity(0.1),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, IconData icon, String label, int? pageIndex) {
    return ElevatedButton.icon(
      onPressed: label == 'Data'
          ? () {
              final homeState = context.findAncestorStateOfType<_HomeScreenVendorState>();
              if (homeState != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VendorDataPage(canteenId: canteenId),
                  ),
                );
              }
            }
          : pageIndex != null
              ? () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenVendorState>();
                  if (homeState != null) {
                    homeState.setState(() {
                      homeState._selectedIndex = pageIndex;
                    });
                  }
                }
              : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[900],
        minimumSize: const Size(90, 40),
      ),
    );
  }

  String _formatTime(String iso, AppLocalizations l10n) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${l10n.minutesAgo}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}${l10n.hoursAgo}';
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else {
      return '${diff.inDays}${l10n.daysAgo}';
    }
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
  String canteenDescriptionEn = '';
  String canteenHours = '';
  String canteenAddress = '';
  String canteenId = '';
  File? _avatarImage;
  List<String> envImages = [];
  List<String> announcements = [];
  final TextEditingController _announcementCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEnvImages();
    _loadAnnouncements();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('currentUsername') ?? 'No Username';
      nickname = prefs.getString('nickname_$username') ?? username;
      canteenName = prefs.getString('canteen_$username') ?? 'No Canteen Name';
      canteenDescription = prefs.getString('canteen_desc_$username') ?? '';
      canteenDescriptionEn = prefs.getString('canteen_desc_en_$username') ?? '';
      canteenHours = prefs.getString('canteen_hours_$username') ?? '';
      canteenAddress = prefs.getString('canteen_addr_$username') ?? '';
      canteenId = prefs.getString('canteenId_$username') ?? '';
      String? avatarPath = prefs.getString('currentUserAvatar');
      if (avatarPath != null && avatarPath.isNotEmpty) {
        _avatarImage = File(avatarPath);
      }
    });
  }

  Future<void> _loadEnvImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      envImages = prefs.getStringList('env_images_$username') ?? [];
    });
  }

  Future<void> _saveEnvImages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('env_images_$username', envImages);
  }

  Future<void> _pickEnvImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        envImages.add(image.path);
      });
      await _saveEnvImages();
    }
  }

  Future<void> _loadAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      announcements = prefs.getStringList('announcements_$username') ?? [];
    });
  }

  Future<void> _addAnnouncement() async {
    final prefs = await SharedPreferences.getInstance();
    if (_announcementCtrl.text.trim().isEmpty) return;
    final content = _announcementCtrl.text.trim();
    setState(() {
      announcements.insert(0, content);
      _announcementCtrl.clear();
    });
    await prefs.setStringList('announcements_$username', announcements);
    // 同步写入全局 announcements，供学生端读取
    final globalKey = 'announcements';
    List<String> globalList = prefs.getStringList(globalKey) ?? [];
    final ann = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': content,
      'canteenId': canteenId,
      'createdAt': DateTime.now().toIso8601String(),
    };
    globalList.insert(0, jsonEncode(ann));
    await prefs.setStringList(globalKey, globalList);
  }

  Future<void> _saveCanteenDescription(String desc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_desc_$username', desc);
    setState(() {
      canteenDescription = desc;
    });
  }

  Future<void> _saveCanteenDescriptionEn(String desc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canteen_desc_en_$username', desc);
    setState(() {
      canteenDescriptionEn = desc;
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

  // 恢复头像上传方法
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
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
          const SizedBox(height: 20),
          Text('Environment Images', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...envImages.map((img) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.file(File(img), width: 80, height: 80, fit: BoxFit.cover),
                )),
                IconButton(
                  icon: Icon(Icons.add_a_photo, color: Colors.blue),
                  onPressed: _pickEnvImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _announcementCtrl,
                  decoration: InputDecoration(hintText: 'Enter announcement...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.green),
                onPressed: _addAnnouncement,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: announcements.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• $a', style: TextStyle(color: Colors.black87)),
            )).toList(),
          ),
          // 数据统计区
          const SizedBox(height: 20),
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

// 添加 _getVendorStats 方法
Future<Map<String, dynamic>> _getVendorStats(String canteenId) async {
  final prefs = await SharedPreferences.getInstance();
  final dishKey = 'canteen_dishes_$canteenId';
  final reviewKey = 'canteen_reviews_$canteenId';
  final dishData = prefs.getString(dishKey);
  final dishList = dishData != null ? List<Map<String, dynamic>>.from(jsonDecode(dishData)) : [];
  final reviewStrings = prefs.getStringList(reviewKey) ?? [];
  final reviews = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
  double sum = 0;
  int count = 0;
  for (var r in reviews) {
    if (r['rating'] != null) {
      sum += double.tryParse(r['rating'].toString()) ?? 0;
      count++;
    }
  }
  return {
    'dishCount': dishList.length,
    'reviewCount': reviews.length,
    'avgRating': count > 0 ? sum / count : 0,
  };
}

// 在 VendorReviewsPage 页首添加数据统计区
// 1. 在 VendorReviewsPage build 方法顶部插入 FutureBuilder，展示数据统计
// 2. 统计最喜欢的菜品（出现次数最多的菜品名）
Future<Map<String, dynamic>> _getReviewStats(String canteenId) async {
  final prefs = await SharedPreferences.getInstance();
  final reviewKey = 'canteen_reviews_${canteenId}';
  final reviewStrings = prefs.getStringList(reviewKey) ?? [];
  final reviews = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
  double sum = 0;
  int count = 0;
  Map<String, int> dishCount = {};
  for (var r in reviews) {
    if (r['rating'] != null) {
      sum += double.tryParse(r['rating'].toString()) ?? 0;
      count++;
    }
    if (r['dish'] != null && r['dish'].toString().isNotEmpty) {
      dishCount[r['dish']] = (dishCount[r['dish']] ?? 0) + 1;
    }
  }
  String favoriteDish = '';
  int maxCount = 0;
  dishCount.forEach((dish, c) {
    if (c > maxCount) {
      maxCount = c;
      favoriteDish = dish;
    }
  });
  return {
    'reviewCount': reviews.length,
    'avgRating': count > 0 ? sum / count : 0,
    'favoriteDish': favoriteDish.isNotEmpty ? favoriteDish : 'N/A',
  };
}

// 1. 新建 VendorDataPage
class VendorDataPage extends StatelessWidget {
  final String canteenId;
  const VendorDataPage({super.key, required this.canteenId});

  Future<Map<String, dynamic>> _getVendorStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dishKey = 'canteen_dishes_$canteenId';
    final reviewKey = 'canteen_reviews_$canteenId';
    final dishData = prefs.getString(dishKey);
    final dishList = dishData != null ? List<Map<String, dynamic>>.from(jsonDecode(dishData)) : [];
    final reviewStrings = prefs.getStringList(reviewKey) ?? [];
    final reviews = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
    double sum = 0;
    int count = 0;
    Map<String, int> dishCount = {};
    for (var r in reviews) {
      if (r['rating'] != null) {
        sum += double.tryParse(r['rating'].toString()) ?? 0;
        count++;
      }
      if (r['dish'] != null && r['dish'].toString().isNotEmpty) {
        dishCount[r['dish']] = (dishCount[r['dish']] ?? 0) + 1;
      }
    }
    String favoriteDish = '';
    int maxCount = 0;
    dishCount.forEach((dish, c) {
      if (c > maxCount) {
        maxCount = c;
        favoriteDish = dish;
      }
    });
    return {
      'dishCount': dishList.length,
      'reviewCount': reviews.length,
      'avgRating': count > 0 ? sum / count : 0,
      'favoriteDish': favoriteDish.isNotEmpty ? favoriteDish : 'N/A',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Statistics')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getVendorStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 24),
                _buildStatRow('Total Dishes', stats['dishCount'].toString()),
                const SizedBox(height: 12),
                _buildStatRow('Total Reviews', stats['reviewCount'].toString()),
                const SizedBox(height: 12),
                _buildStatRow('Average Rating', stats['avgRating'].toStringAsFixed(1)),
                const SizedBox(height: 12),
                _buildStatRow('Most Favorite Dish', stats['favoriteDish']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        Text(label + ':', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
