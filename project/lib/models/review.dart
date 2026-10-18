class Review {
  final int? id;
  final int restaurantId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    this.id,
    required this.restaurantId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      restaurantId: map['restaurantId'],
      userName: map['userName'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}