import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/models/review.dart';
import 'dart:convert';

class StudentCanteenReviewDialog extends StatefulWidget {
  final String canteenId;
  final String canteenName;

  const StudentCanteenReviewDialog({
    super.key,
    required this.canteenId,
    required this.canteenName,
  });

  @override
  State<StudentCanteenReviewDialog> createState() => _StudentCanteenReviewDialogState();
}

class _StudentCanteenReviewDialogState extends State<StudentCanteenReviewDialog> {
  double _rating = 0.0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectRating)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('currentUsername') ?? '';
    final nickname = prefs.getString('nickname_$currentUsername') ?? currentUsername;

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      canteenId: widget.canteenId,
      username: currentUsername,
      nickname: nickname,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    // 保存评价到本地存储
    List<String> reviews = prefs.getStringList('canteen_reviews') ?? [];
    reviews.add(jsonEncode(review.toJson()));
    await prefs.setStringList('canteen_reviews', reviews);

    if (mounted) {
      Navigator.of(context).pop(review);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reviewSubmitted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.writeReview),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.canteenName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectRating,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.writeYourReview,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseWriteReview;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16a951),
          ),
          child: Text(
            l10n.submit,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 