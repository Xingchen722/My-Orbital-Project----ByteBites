import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VendorReviewsPage extends StatefulWidget {
  final String canteenId;
  const VendorReviewsPage({super.key, required this.canteenId});

  @override
  State<VendorReviewsPage> createState() => _VendorReviewsPageState();
}

class _VendorReviewsPageState extends State<VendorReviewsPage> {
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_reviews_${widget.canteenId}';
    List<String> reviewStrings = prefs.getStringList(key) ?? [];
    setState(() {
      reviews = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
    });
  }

  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_reviews_${widget.canteenId}';
    await prefs.setStringList(key, reviews.map((r) => jsonEncode(r)).toList());
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
    await prefs.setBool('canteen_unread_${canteenId}', true);
  }

  void _showReplyDialog(int index) {
    final replyCtrl = TextEditingController(text: reviews[index]['reply'] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to Review'),
        content: TextField(
          controller: replyCtrl,
          decoration: InputDecoration(labelText: 'Reply'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                reviews[index]['reply'] = replyCtrl.text.trim();
              });
              await _saveReviews();
              final l10n = AppLocalizations.of(context)!;
              await _addAnnouncement(l10n.vendorReplied, widget.canteenId);
              Navigator.pop(context);
            },
            child: Text('Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Management')),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, i) {
          final r = reviews[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(r['comment'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rating: ${r['rating'] ?? ''}'),
                  if (r['reply'] != null && r['reply'].toString().isNotEmpty)
                    Text('Vendor Reply: ${r['reply']}', style: TextStyle(color: Colors.green)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.reply, color: Colors.blue),
                onPressed: () => _showReplyDialog(i),
              ),
            ),
          );
        },
      ),
    );
  }
} 