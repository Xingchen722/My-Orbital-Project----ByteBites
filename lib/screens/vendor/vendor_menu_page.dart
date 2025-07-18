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
        title: Text(dish == null ? AppLocalizations.of(context)!.addDish : AppLocalizations.of(context)!.editDish),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dishName)),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description)),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.price), keyboardType: TextInputType.number),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
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
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.menuManagement)),
      body: ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, i) {
          final dish = dishes[i];
          return ListTile(
            leading: dish['imageUrl'] != null
                ? Image.file(File(dish['imageUrl']), width: 48, height: 48, fit: BoxFit.cover)
                : Icon(Icons.image, size: 48, color: Colors.grey[400]),
            title: Row(
              children: [
                Text(dish['name'] ?? ''),
                const SizedBox(width: 8),
                if (!(dish['available'] ?? true))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(AppLocalizations.of(context)!.unshelve, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
            subtitle: Text('S\$${dish['price']?.toStringAsFixed(2) ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 上下架按钮
                IconButton(
                  icon: Icon(
                    dish['available'] ?? true ? Icons.visibility : Icons.visibility_off,
                    color: dish['available'] ?? true ? Colors.green : Colors.grey,
                  ),
                  tooltip: dish['available'] ?? true ? AppLocalizations.of(context)!.unshelve : AppLocalizations.of(context)!.shelve,
                  onPressed: () async {
                    setState(() {
                      dishes[i]['available'] = !(dish['available'] ?? true);
                    });
                    await _saveDishes();
                  },
                ),
                // 上移
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                  tooltip: AppLocalizations.of(context)!.moveUp,
                  onPressed: i > 0
                      ? () async {
                          setState(() {
                            final temp = dishes[i - 1];
                            dishes[i - 1] = dishes[i];
                            dishes[i] = temp;
                          });
                          await _saveDishes();
                        }
                      : null,
                ),
                // 下移
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.blue),
                  tooltip: AppLocalizations.of(context)!.moveDown,
                  onPressed: i < dishes.length - 1
                      ? () async {
                          setState(() {
                            final temp = dishes[i + 1];
                            dishes[i + 1] = dishes[i];
                            dishes[i] = temp;
                          });
                          await _saveDishes();
                        }
                      : null,
                ),
                // 复制
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.purple),
                  tooltip: AppLocalizations.of(context)!.copy,
                  onPressed: () async {
                    final newDish = Map<String, dynamic>.from(dish);
                    newDish['id'] = DateTime.now().millisecondsSinceEpoch.toString();
                    newDish['name'] = newDish['name'] + ' (${AppLocalizations.of(context)!.copy})';
                    setState(() {
                      dishes.insert(i + 1, newDish);
                    });
                    await _saveDishes();
                  },
                ),
                // 编辑
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  tooltip: AppLocalizations.of(context)!.edit,
                  onPressed: () => _showDishDialog(dish: dish, index: i),
                ),
                // 删除
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: AppLocalizations.of(context)!.cancel,
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
        tooltip: AppLocalizations.of(context)!.add,
        child: Icon(Icons.add),
      ),
    );
  }
} 