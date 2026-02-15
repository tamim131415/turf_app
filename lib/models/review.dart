import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerifiedPurchase;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerifiedPurchase = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      orderId: map['orderId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
    );
  }

  // Helper method to parse both String and Timestamp
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review.fromMap(data, doc.id);
  }
}
