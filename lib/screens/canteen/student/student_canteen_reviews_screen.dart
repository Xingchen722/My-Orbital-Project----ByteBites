import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/models/review.dart';
import 'dart:convert';

class StudentCanteenReviewsScreen extends StatefulWidget {
  final String canteenId;
  final String canteenName;

  const StudentCanteenReviewsScreen({
    super.key,
    required this.canteenId,
    required this.canteenName,
  });

  @override
  State<StudentCanteenReviewsScreen> createState() => _StudentCanteenReviewsScreenState();
}

class _StudentCanteenReviewsScreenState extends State<StudentCanteenReviewsScreen> {
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'canteen_reviews_${widget.canteenId}';
    List<String> reviewStrings = prefs.getStringList(key) ?? [];
    
    List<Review> reviews = [];
    for (String reviewString in reviewStrings) {
      try {
        final reviewMap = jsonDecode(reviewString) as Map<String, dynamic>;
        final review = Review.fromJson(reviewMap);
        reviews.add(review);
      } catch (e) {
        // 忽略无效的评价数据
        continue;
      }
    }

    // 按时间排序，最新的在前面
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    double totalRating = 0.0;
    for (Review review in reviews) {
      totalRating += review.rating;
    }
    double averageRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

    setState(() {
      _reviews = reviews;
      _averageRating = averageRating;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviews),
        backgroundColor: const Color(0xFF16a951),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 平均评分显示
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.canteenName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < _averageRating.floor() 
                                      ? Icons.star 
                                      : (index < _averageRating ? Icons.star_half : Icons.star_border),
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${_averageRating.toStringAsFixed(1)} (${_reviews.length} ${l10n.reviews})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 评价列表
                Expanded(
                  child: _reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noReviewsYet,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[300],
                                          child: Text(
                                            review.nickname.isNotEmpty 
                                                ? review.nickname[0].toUpperCase()
                                                : review.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.nickname.isNotEmpty 
                                                    ? review.nickname 
                                                    : review.username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(review.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < review.rating 
                                                  ? Icons.star 
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    if (review.comment.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        review.comment,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      if ((review as dynamic).reply != null && (review as dynamic).reply.toString().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '${AppLocalizations.of(context)!.vendorReply}: ${(review as dynamic).reply}',
                                          style: const TextStyle(fontSize: 13, color: Colors.green, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ],
                                  ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} ${l10n.minutesAgo}';
      }
      return '${difference.inHours} ${l10n.hoursAgo}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 