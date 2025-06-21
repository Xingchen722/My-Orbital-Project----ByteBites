class Review {
  final String id;
  final String canteenId;
  final String username;
  final String nickname;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.canteenId,
    required this.username,
    required this.nickname,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      canteenId: json['canteenId'] as String,
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
      'username': username,
      'nickname': nickname,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 