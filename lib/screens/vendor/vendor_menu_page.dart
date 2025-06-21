import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VendorMenuPage extends StatefulWidget {
  final String canteenId;
  const VendorMenuPage({super.key, required this.canteenId});

  @override
  State<VendorMenuPage> createState() => _VendorMenuPageState();
}

class _VendorMenuPageState extends State<VendorMenuPage> {
  List<Map<String, dynamic>> dishes = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_dishes_${widget.canteenId}';
    final data = prefs.getString(key);
    if (data != null) {
      setState(() {
        dishes = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_dishes_${widget.canteenId}';
    await prefs.setString(key, jsonEncode(dishes));
    // 生成变更消息（多语言）
    final l10n = AppLocalizations.of(context)!;
    await _addAnnouncement(l10n.menuChanged, widget.canteenId);
    // 设置未读标记
    await prefs.setBool('canteen_unread_${widget.canteenId}', true);
  }

  Future<void> _addAnnouncement(String msg, String canteenId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'announcements';
    List<String> list = prefs.getStringList(key) ?? [];
    final ann = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': msg,
      'canteenId': canteenId,
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.insert(0, jsonEncode(ann));
    await prefs.setStringList(key, list);
  }

  void _showDishDialog({Map<String, dynamic>? dish, int? index}) {
    final nameCtrl = TextEditingController(text: dish?['name'] ?? '');
    final descCtrl = TextEditingController(text: dish?['description'] ?? '');
    final priceCtrl = TextEditingController(text: dish?['price']?.toString() ?? '');
    String? imagePath = dish?['imageUrl'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dish == null ? 'Add Dish' : 'Edit Dish'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Dish Name')),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final img = await picker.pickImage(source: ImageSource.gallery);
                  if (img != null) {
                    setState(() {
                      imagePath = img.path;
                    });
                  }
                },
                child: imagePath != null
                    ? Image.file(File(imagePath!), width: 80, height: 80, fit: BoxFit.cover)
                    : Container(
                        width: 80, height: 80, color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isEmpty) return;
              final newDish = {
                'id': dish?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                'name': name,
                'description': desc,
                'price': price,
                'imageUrl': imagePath,
                'available': true,
              };
              setState(() {
                if (index != null) {
                  dishes[index] = newDish;
                } else {
                  dishes.add(newDish);
                }
              });
              await _saveDishes();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Management')),
      body: ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, i) {
          final dish = dishes[i];
          return ListTile(
            leading: dish['imageUrl'] != null
                ? Image.file(File(dish['imageUrl']), width: 48, height: 48, fit: BoxFit.cover)
                : Icon(Icons.image, size: 48, color: Colors.grey[400]),
            title: Text(dish['name'] ?? ''),
            subtitle: Text('S\$${dish['price']?.toStringAsFixed(2) ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _showDishDialog(dish: dish, index: i),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    setState(() {
                      dishes.removeAt(i);
                    });
                    await _saveDishes();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDishDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
} 