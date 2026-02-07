class ReviewModel {
  final String id;
  final int productId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'].toString(),
      productId: json['productId'] ?? 0,
      userName: json['userName'] ?? 'Anonymous',
      userImage: json['userImage'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}
