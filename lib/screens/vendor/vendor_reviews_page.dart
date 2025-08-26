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
  bool showOnlyUnreplied = false;
  int totalCount = 0;
  double avgRating = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_reviews_${widget.canteenId}';
    List<String> reviewStrings = prefs.getStringList(key) ?? [];
    final loaded = reviewStrings.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
    double sum = 0;
    int count = 0;
    for (var r in loaded) {
      if (r['rating'] != null) {
        sum += double.tryParse(r['rating'].toString()) ?? 0;
        count++;
      }
    }
    setState(() {
      reviews = loaded;
      totalCount = count;
      avgRating = count > 0 ? sum / count : 0;
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
    final l10n = AppLocalizations.of(context)!;
    final filtered = showOnlyUnreplied
        ? reviews.where((r) => (r['reply'] ?? '').toString().isEmpty).toList()
        : reviews;
    return Scaffold(
      appBar: AppBar(title: Text('Review Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reviews: $totalCount', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Rating: ${avgRating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Checkbox(
                      value: showOnlyUnreplied,
                      onChanged: (v) => setState(() => showOnlyUnreplied = v ?? false),
                    ),
                    Text(l10n.vendorReply ?? 'Only Unreplied'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final r = filtered[i];
                final unreplied = (r['reply'] ?? '').toString().isEmpty;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: unreplied ? Colors.yellow[100] : null,
                  child: ListTile(
                    title: Text(r['comment'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: ${r['rating'] ?? ''}'),
                        if (r['reply'] != null && r['reply'].toString().isNotEmpty)
                          Text('Vendor Reply: ${r['reply']}', style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.reply, color: Colors.blue),
                      onPressed: () => _showReplyDialog(reviews.indexOf(r)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 