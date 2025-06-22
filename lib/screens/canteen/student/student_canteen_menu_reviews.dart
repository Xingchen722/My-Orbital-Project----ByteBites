import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/canteen.dart';
import 'package:flutter_application_1/models/dish_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentCanteenMenuReviews extends StatefulWidget {
  final Canteen canteen;
  const StudentCanteenMenuReviews({super.key, required this.canteen});

  @override
  State<StudentCanteenMenuReviews> createState() => _StudentCanteenMenuReviewsState();
}

class _StudentCanteenMenuReviewsState extends State<StudentCanteenMenuReviews> {
  Map<String, List<DishReview>> dishReviews = {};
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('currentUsername');
    List<String> reviewStrings = prefs.getStringList('dish_reviews') ?? [];
    Map<String, List<DishReview>> map = {};
    for (String reviewString in reviewStrings) {
      try {
        final reviewMap = jsonDecode(reviewString) as Map<String, dynamic>;
        final review = DishReview.fromJson(reviewMap);
        if (review.canteenId == widget.canteen.id) {
          map.putIfAbsent(review.dishName, () => []).add(review);
        }
      } catch (_) {}
    }
    setState(() {
      dishReviews = map;
    });
  }

  Future<void> _addOrEditReview(String dishName, [DishReview? editing]) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString('nickname_$currentUsername') ?? currentUsername ?? '';
    final formKey = GlobalKey<FormState>();
    bool isEdit = editing != null;

    double rating = editing?.rating ?? 0.0;
    final controller = TextEditingController(text: editing?.comment ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? l10n.edit : l10n.add),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                    onPressed: () {
                      setState(() {
                        rating = i + 1.0;
                      });
                    },
                  )),
                ),
                TextFormField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.writeYourReview),
                  validator: (v) => v == null || v.trim().isEmpty ? l10n.pleaseWriteReview : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate() || rating == 0.0) return;
              List<String> reviewStrings = prefs.getStringList('dish_reviews') ?? [];
              if (isEdit) {
                reviewStrings.removeWhere((s) {
                  final m = jsonDecode(s);
                  return m['id'] == editing!.id;
                });
              }
              final review = DishReview(
                id: isEdit ? editing!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                canteenId: widget.canteen.id,
                dishName: dishName,
                username: currentUsername!,
                nickname: nickname,
                rating: rating,
                comment: controller.text.trim(),
                createdAt: DateTime.now(),
              );
              reviewStrings.add(jsonEncode(review.toJson()));
              await prefs.setStringList('dish_reviews', reviewStrings);
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(DishReview review) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reviewStrings = prefs.getStringList('dish_reviews') ?? [];
    reviewStrings.removeWhere((s) {
      final m = jsonDecode(s);
      return m['id'] == review.id;
    });
    await prefs.setStringList('dish_reviews', reviewStrings);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.canteen.name} ${l10n.menuNotification(widget.canteen.name)}'),
        backgroundColor: const Color(0xFF16a951),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: widget.canteen.menu.map((dish) {
          final reviews = dishReviews[dish] ?? [];
          final myReview = reviews.where((r) => r.username == currentUsername).toList();
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: dish.toLowerCase().contains('chicken rice')
                          ? () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: InteractiveViewer(
                                    child: Image.asset('assets/images/chicken_rice.png'),
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: dish.toLowerCase().contains('chicken rice')
                            ? Image.asset('assets/images/chicken_rice.png', fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image, color: Colors.grey[400], size: 64),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(dish, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addOrEditReview(dish, myReview.isNotEmpty ? myReview.first : null),
                    icon: Icon(myReview.isNotEmpty ? Icons.edit : Icons.rate_review),
                    label: Text(myReview.isNotEmpty ? l10n.edit : l10n.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: myReview.isNotEmpty ? Colors.orange : const Color(0xFF16a951),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    Text(l10n.noReviewsYet, style: TextStyle(color: Colors.grey[600])),
                  ...reviews.map((r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(r.nickname.isNotEmpty ? r.nickname[0] : r.username[0])),
                        title: Row(
                          children: [
                            Text(r.nickname.isNotEmpty ? r.nickname : r.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.comment),
                            if ((r as dynamic).reply != null && (r as dynamic).reply.toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${AppLocalizations.of(context)!.vendorReply}: ${(r as dynamic).reply}',
                                  style: const TextStyle(fontSize: 13, color: Colors.green, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                        trailing: r.username == currentUsername
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _addOrEditReview(dish, r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteReview(r),
                                  ),
                                ],
                              )
                            : null,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 