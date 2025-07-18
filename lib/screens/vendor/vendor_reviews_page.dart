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
  String filter = 'all'; // 筛选条件

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    double total = 0.0;
    for (var r in reviews) {
      total += (r['rating'] ?? 0.0) * 1.0;
    }
    return total / reviews.length;
  }

  double get positiveRate {
    if (reviews.isEmpty) return 0.0;
    int positive = reviews.where((r) => (r['rating'] ?? 0.0) >= 4).length;
    return positive / reviews.length;
  }

  List<Map<String, dynamic>> get filteredReviews {
    if (filter == 'all') return reviews;
    if (filter == 'unreplied') {
      return reviews.where((r) => r['reply'] == null || r['reply'].toString().isEmpty).toList();
    }
    if (filter == 'low') {
      return reviews.where((r) => (r['rating'] ?? 0.0) < 2.5).toList();
    }
    if (filter == 'positive') {
      return reviews.where((r) => (r['rating'] ?? 0.0) >= 4).toList();
    }
    return reviews;
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
        title: Text(AppLocalizations.of(context)!.replyToReview),
        content: TextField(
          controller: replyCtrl,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.reply),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
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
            child: Text(AppLocalizations.of(context)!.reply),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.reviewManagement)),
      body: Column(
        children: [
          // 统计信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(AppLocalizations.of(context)!.selectRating, averageRating.toStringAsFixed(2), Colors.blue),
                _buildStatCard(AppLocalizations.of(context)!.positiveRating, '${(positiveRate * 100).toStringAsFixed(1)}%', Colors.green),
                _buildStatCard(AppLocalizations.of(context)!.reviews, reviews.length.toString(), Colors.orange),
              ],
            ),
          ),
          // 筛选按钮
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(AppLocalizations.of(context)!.all, 'all'),
                _buildFilterButton(AppLocalizations.of(context)!.unreplied, 'unreplied'),
                _buildFilterButton(AppLocalizations.of(context)!.lowRating, 'low'),
                _buildFilterButton(AppLocalizations.of(context)!.positiveRating, 'positive'),
              ],
            ),
          ),
          const Divider(),
          // 评价列表
          Expanded(
            child: ListView.builder(
              itemCount: filteredReviews.length,
              itemBuilder: (context, i) {
                final r = filteredReviews[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(r['comment'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${AppLocalizations.of(context)!.selectRating}: ${r['rating'] ?? ''}'),
                        if (r['reply'] != null && r['reply'].toString().isNotEmpty)
                          Text('${AppLocalizations.of(context)!.vendorReply}: ${r['reply']}', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.reply, color: Colors.blue),
                      tooltip: AppLocalizations.of(context)!.edit,
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

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Container(
        width: 90,
        height: 60,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final selected = filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            filter = value;
          });
        },
      ),
    );
  }
} 