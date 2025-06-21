import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/canteen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_review_dialog.dart';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_reviews_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/review.dart';
import 'dart:convert';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_menu_reviews.dart';

class StudentCanteenCard extends StatefulWidget {
  final Canteen canteen;

  const StudentCanteenCard({
    super.key,
    required this.canteen,
  });

  @override
  State<StudentCanteenCard> createState() => _StudentCanteenCardState();
}

class _StudentCanteenCardState extends State<StudentCanteenCard> {
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reviewStrings = prefs.getStringList('canteen_reviews') ?? [];
    
    List<Review> reviews = [];
    for (String reviewString in reviewStrings) {
      try {
        final reviewMap = jsonDecode(reviewString) as Map<String, dynamic>;
        final review = Review.fromJson(reviewMap);
        if (review.canteenId == widget.canteen.id) {
          reviews.add(review);
        }
      } catch (e) {
        continue;
      }
    }

    double totalRating = 0.0;
    for (Review review in reviews) {
      totalRating += review.rating;
    }
    double averageRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

    setState(() {
      _averageRating = averageRating;
      _reviewCount = reviews.length;
      _isLoadingRating = false;
    });
  }

  String _getLocalizedDescription(BuildContext context, Canteen canteen) {
    final l10n = AppLocalizations.of(context)!;
    switch (canteen.id) {
      case '1':
        return l10n.canteenDescriptionSummit;
      case '2':
        return l10n.canteenDescriptionFrontier;
      case '3':
        return l10n.canteenDescriptionTechno;
      case '4':
        return l10n.canteenDescriptionPGP;
      case '5':
        return l10n.canteenDescriptionDeck;
      case '6':
        return l10n.canteenDescriptionTerrace;
      case '7':
        return l10n.canteenDescriptionYIH;
      case '8':
        return l10n.canteenDescriptionFineFood;
      default:
        return canteen.description;
    }
  }

  Future<void> _showReviewDialog() async {
    final result = await showDialog<Review>(
      context: context,
      builder: (context) => StudentCanteenReviewDialog(
        canteenId: widget.canteen.id,
        canteenName: widget.canteen.name,
      ),
    );

    if (result != null) {
      // 重新加载评分
      _loadRating();
    }
  }

  void _showReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentCanteenReviewsScreen(
          canteenId: widget.canteen.id,
          canteenName: widget.canteen.name,
        ),
      ),
    ).then((_) {
      // 返回时重新加载评分
      _loadRating();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Icon(
                Icons.restaurant,
                size: 64,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.canteen.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.canteen.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_getLocalizedDescription(context, widget.canteen)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.canteen.operatingHours,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 评分显示
                if (!_isLoadingRating) ...[
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < _averageRating.floor() 
                              ? Icons.star 
                              : (index < _averageRating ? Icons.star_half : Icons.star_border),
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        _reviewCount > 0 
                            ? '${_averageRating.toStringAsFixed(1)} (${_reviewCount} ${l10n.reviews})'
                            : l10n.noReviewsYet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // 按钮行
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentCanteenMenuReviews(canteen: widget.canteen),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16a951),
                          minimumSize: const Size(0, 45),
                        ),
                        child: Text(
                          l10n.viewMenu,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showReviewDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(0, 45),
                        ),
                        child: Text(
                          l10n.writeReview,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 新增：菜单与点评按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restaurant_menu),
                    label: Text(l10n.menuAndReviews),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentCanteenMenuReviews(canteen: widget.canteen),
                        ),
                      );
                    },
                  ),
                ),
                // 查看评价按钮
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _showReviews,
                    child: Text(
                      l10n.viewAllReviews,
                      style: const TextStyle(color: Color(0xFF16a951)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 