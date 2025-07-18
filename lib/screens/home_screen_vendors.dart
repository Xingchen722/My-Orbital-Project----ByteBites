import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/screens/vendor/vendor_menu_page.dart';
import 'package:flutter_application_1/screens/vendor/vendor_reviews_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/main.dart';

class VendorCanteenPage extends StatefulWidget {
  const VendorCanteenPage({super.key});

  @override
  State<VendorCanteenPage> createState() => _VendorCanteenPageState();
}

class _VendorCanteenPageState extends State<VendorCanteenPage> {
  int todayOrderCount = 0;
  double totalSales = 0.0;
  int pendingOrderCount = 0; // 这里用未回复评价数模拟
  Map<String, dynamic>? latestReview;
  String canteenId = '';
  List<Map<String, dynamic>> dishes = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? '';
    canteenId = prefs.getString('canteenId_$username') ?? '1';
    // 加载菜品
    final dishKey = 'canteen_dishes_$canteenId';
    final dishData = prefs.getString(dishKey);
    if (dishData != null) {
      dishes = List<Map<String, dynamic>>.from(jsonDecode(dishData));
    }
    // 加载评价
    final reviewKey = 'canteen_reviews_$canteenId';
    List<String> reviewStrings = prefs.getStringList(reviewKey) ?? [];
    int todayCount = 0;
    double sales = 0.0;
    int pendingCount = 0;
    Map<String, dynamic>? latest;
    DateTime now = DateTime.now();
    for (String reviewString in reviewStrings) {
      try {
        final review = Map<String, dynamic>.from(jsonDecode(reviewString));
        DateTime createdAt = DateTime.parse(review['createdAt']);
        if (createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day) {
          todayCount++;
        }
        // 用菜品价格估算销售额
        if (review['comment'] != null && review['comment'].toString().isNotEmpty) {
          // 假设评价里有菜品名字段（如有）
          String? dishName = review['dishName'];
          if (dishName != null) {
            final dish = dishes.firstWhere((d) => d['name'] == dishName, orElse: () => {});
            if (dish.isNotEmpty && dish['price'] != null) {
              sales += (dish['price'] as num).toDouble();
            }
          }
        }
        // 未回复评价模拟待处理订单
        if (review['reply'] == null || review['reply'].toString().isEmpty) {
          pendingCount++;
        }
        // 记录最新评价
        if (latest == null || createdAt.isAfter(DateTime.parse(latest['createdAt']))) {
          latest = review;
        }
      } catch (_) {}
    }
    setState(() {
      todayOrderCount = todayCount;
      totalSales = sales;
      pendingOrderCount = pendingCount;
      latestReview = latest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.vendorDashboard, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(l10n.todayOrders, todayOrderCount.toString(), Colors.blue),
              _buildStatCard(l10n.totalSales, 'S\$${totalSales.toStringAsFixed(2)}', Colors.green),
              _buildStatCard(l10n.pendingOrders, pendingOrderCount.toString(), Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.quickAccess, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(context, Icons.restaurant_menu, l10n.menuManagement, 1),
              _buildQuickButton(context, Icons.rate_review, l10n.reviewManagement, 2),
              _buildQuickButton(context, Icons.bar_chart, l10n.dataAnalysis, 4),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.recentReview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          latestReview != null
              ? Card(
                  child: ListTile(
                    title: Text(latestReview!['comment'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l10n.selectRating}: ${latestReview!['rating'] ?? ''}'),
                        if (latestReview!['reply'] != null && latestReview!['reply'].toString().isNotEmpty)
                          Text('${l10n.vendorReply}: ${latestReview!['reply']}', style: const TextStyle(color: Colors.green)),
                        Text('${l10n.minutesAgo}: ${latestReview!['createdAt']?.toString().substring(0, 16) ?? ''}'),
                      ],
                    ),
                  ),
                )
              : Text(l10n.noReview),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Container(
        width: 100,
        height: 80,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, IconData icon, String label, int pageIndex) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // 跳转到对应页面
            final parentState = context.findAncestorStateOfType<_HomeScreenVendorState>();
            if (parentState != null) {
              parentState.setState(() {
                parentState._selectedIndex = pageIndex;
              });
            }
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue[50],
            child: Icon(icon, size: 32, color: Colors.blue[700]),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
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
  List<String> environmentImages = [];
  String announcement = '';
  String canteenDescriptionZh = '';
  String canteenDescriptionEn = '';
  String currentLang = 'zh';

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
      environmentImages = prefs.getStringList('env_imgs_$username') ?? [];
      announcement = prefs.getString('announcement_$username') ?? '';
      canteenDescriptionZh = prefs.getString('canteen_desc_zh_$username') ?? '';
      canteenDescriptionEn = prefs.getString('canteen_desc_en_$username') ?? '';
      currentLang = prefs.getString('profile_lang_$username') ?? 'zh';
    });
  }

  Future<void> _pickEnvironmentImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        environmentImages.addAll(images.map((img) => img.path));
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('env_imgs_$username', environmentImages);
    }
  }

  Future<void> _removeEnvironmentImage(int index) async {
    setState(() {
      environmentImages.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('env_imgs_$username', environmentImages);
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

  Future<void> _saveCanteenDescription(String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (currentLang == 'zh') {
      await prefs.setString('canteen_desc_zh_$username', value);
      setState(() {
        canteenDescriptionZh = value;
      });
    } else {
      await prefs.setString('canteen_desc_en_$username', value);
      setState(() {
        canteenDescriptionEn = value;
      });
    }
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

  Future<void> _saveAnnouncement(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('announcement_$username', value);
    setState(() {
      announcement = value;
    });
    // 同步写入全局公告列表
    final key = 'announcements';
    List<String> list = prefs.getStringList(key) ?? [];
    final ann = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': '$canteenName：$value',
      'canteenId': canteenId,
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.insert(0, jsonEncode(ann));
    await prefs.setStringList(key, list);
  }

  void _switchLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_lang_$username', lang);
    setState(() {
      currentLang = lang;
    });
    // 全局语言切换
    final ByteBitesAppState? appState = context.findAncestorStateOfType<ByteBitesAppState>();
    if (appState != null) {
      appState.changeLanguage(Locale(lang));
    }
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
    final l10n = AppLocalizations.of(context)!;
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
          // 多语言餐厅介绍
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(l10n.chinese),
                selected: currentLang == 'zh',
                onSelected: (_) => _switchLang('zh'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(l10n.english),
                selected: currentLang == 'en',
                onSelected: (_) => _switchLang('en'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: Text(l10n.canteenDescription),
              subtitle: Text(
                currentLang == 'zh'
                    ? (canteenDescriptionZh.isNotEmpty ? canteenDescriptionZh : l10n.noDescription)
                    : (canteenDescriptionEn.isNotEmpty ? canteenDescriptionEn : l10n.noDescription),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  final ctrl = TextEditingController(
                    text: currentLang == 'zh' ? canteenDescriptionZh : canteenDescriptionEn,
                  );
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.editCanteenDescription),
                      content: TextField(
                        controller: ctrl,
                        maxLines: 4,
                        decoration: InputDecoration(hintText: l10n.enterCanteenDescription),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                        ElevatedButton(
                          onPressed: () async {
                            await _saveCanteenDescription(ctrl.text.trim());
                            Navigator.pop(context);
                          },
                          child: Text(l10n.save),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: l10n.openingHours,
            value: canteenHours,
            onSave: _saveCanteenHours,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: l10n.address,
            value: canteenAddress,
            onSave: _saveCanteenAddress,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: l10n.canteenId,
            value: canteenId,
            onSave: _saveCanteenId,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 340,
              child: Card(
                color: Colors.yellow[100],
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.campaign, color: Colors.orange),
                  title: Text(l10n.announcement),
                  subtitle: Text(announcement.isNotEmpty ? announcement : l10n.noAnnouncement),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      final ctrl = TextEditingController(text: announcement);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.editAnnouncement),
                          content: TextField(
                            controller: ctrl,
                            maxLines: 3,
                            decoration: InputDecoration(hintText: l10n.enterAnnouncementContent),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                            ElevatedButton(
                              onPressed: () async {
                                await _saveAnnouncement(ctrl.text.trim());
                                Navigator.pop(context);
                              },
                              child: Text(l10n.save),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 环境图片展示区
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(l10n.canteenEnvironmentImages, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                  onPressed: _pickEnvironmentImages,
                  tooltip: l10n.uploadEnvironmentImages,
                ),
              ],
            ),
          ),
          if (environmentImages.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: environmentImages.length,
                itemBuilder: (context, i) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(environmentImages[i]),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeEnvironmentImage(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            label: Text(l10n.logout),
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
    final l10n = AppLocalizations.of(context)!;
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
                    SnackBar(content: Text('$label ${l10n.updated}')),
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

class VendorDataAnalysisPage extends StatefulWidget {
  final String canteenId;
  const VendorDataAnalysisPage({super.key, required this.canteenId});

  @override
  State<VendorDataAnalysisPage> createState() => _VendorDataAnalysisPageState();
}

class _VendorDataAnalysisPageState extends State<VendorDataAnalysisPage> {
  List<int> weekOrderCounts = List.filled(7, 0);
  List<String> weekDays = [];
  bool _loading = true;
  Map<String, int> dishOrderCounts = {};
  List<String> topDishes = [];
  Map<String, int> ratingDist = {};

  @override
  void initState() {
    super.initState();
    _loadOrderTrend();
  }

  Future<void> _loadOrderTrend() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_reviews_${widget.canteenId}';
    List<String> reviewStrings = prefs.getStringList(key) ?? [];
    List<int> counts = List.filled(7, 0);
    DateTime now = DateTime.now();
    // 生成一周日期标签
    weekDays = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return "${d.month}/${d.day}";
    });
    Map<String, int> dishCounts = {};
    Map<String, int> ratingCount = {
      '1-2': 0,
      '2-3': 0,
      '3-4': 0,
      '4-5': 0,
    };
    for (String reviewString in reviewStrings) {
      try {
        final review = Map<String, dynamic>.from(jsonDecode(reviewString));
        DateTime createdAt = DateTime.parse(review['createdAt']);
        for (int i = 0; i < 7; i++) {
          final d = now.subtract(Duration(days: 6 - i));
          if (createdAt.year == d.year && createdAt.month == d.month && createdAt.day == d.day) {
            counts[i]++;
          }
        }
        // 统计菜品被评价次数
        String? dishName = review['dishName'];
        if (dishName != null && dishName.isNotEmpty) {
          dishCounts[dishName] = (dishCounts[dishName] ?? 0) + 1;
        }
        // 统计评分分布
        double rating = (review['rating'] ?? 0.0) * 1.0;
        if (rating >= 1 && rating < 2) ratingCount['1-2'] = ratingCount['1-2']! + 1;
        else if (rating >= 2 && rating < 3) ratingCount['2-3'] = ratingCount['2-3']! + 1;
        else if (rating >= 3 && rating < 4) ratingCount['3-4'] = ratingCount['3-4']! + 1;
        else if (rating >= 4 && rating <= 5) ratingCount['4-5'] = ratingCount['4-5']! + 1;
      } catch (_) {}
    }
    // 排序取前5
    List<String> sortedDishes = dishCounts.keys.toList();
    sortedDishes.sort((a, b) => dishCounts[b]!.compareTo(dishCounts[a]!));
    setState(() {
      weekOrderCounts = counts;
      dishOrderCounts = dishCounts;
      topDishes = sortedDishes.take(5).toList();
      ratingDist = ratingCount;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataAnalysis)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.orderTrend, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (weekOrderCounts.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= weekDays.length) return const SizedBox();
                                  return Text(weekDays[idx], style: const TextStyle(fontSize: 12));
                                },
                                reservedSize: 32,
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
                            BarChartRodData(toY: weekOrderCounts[i].toDouble(), color: Colors.blue, width: 18),
                          ])),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.hotDishes, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (topDishes.isEmpty)
                      Text(l10n.noData)
                    else
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (topDishes.map((d) => dishOrderCounts[d] ?? 0).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx >= topDishes.length) return const SizedBox();
                                    return Text(topDishes[idx], style: const TextStyle(fontSize: 12));
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(topDishes.length, (i) => BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: (dishOrderCounts[topDishes[i]] ?? 0).toDouble(), color: Colors.orange, width: 18),
                            ])),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text(l10n.reviewDistribution, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (ratingDist.values.every((v) => v == 0))
                      Text(l10n.noData)
                    else
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: ratingDist['1-2']!.toDouble(),
                                color: Colors.red,
                                title: '1-2',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: ratingDist['2-3']!.toDouble(),
                                color: Colors.orange,
                                title: '2-3',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: ratingDist['3-4']!.toDouble(),
                                color: Colors.blue,
                                title: '3-4',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: ratingDist['4-5']!.toDouble(),
                                color: Colors.green,
                                title: '4-5',
                                radius: 40,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 32,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
      VendorDataAnalysisPage(canteenId: canteenId), // 新增数据分析页
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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Data'), // 新增数据分析tab
        ],
      ),
    );
  }
}
