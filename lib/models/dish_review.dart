class DishReview {
  final String id;
  final String canteenId;
  final String dishName;
  final String username;
  final String nickname;
  final double rating;
  final String comment;
  final DateTime createdAt;

  DishReview({
    required this.id,
    required this.canteenId,
    required this.dishName,
    required this.username,
    required this.nickname,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory DishReview.fromJson(Map<String, dynamic> json) {
    return DishReview(
      id: json['id'] as String,
      canteenId: json['canteenId'] as String,
      dishName: json['dishName'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canteenId': canteenId,
      'dishName': dishName,
      'username': username,
      'nickname': nickname,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 