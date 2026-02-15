import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';
import 'order_status_history.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String customerName;
  final String phoneNumber;
  final String email;
  final String address;
  final String paymentMethod;
  final String orderStatus;
  final DateTime orderDate;
  final List<OrderStatusHistory> statusHistory;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;
  final String? deliveryNote;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.paymentMethod,
    this.orderStatus = 'Pending',
    required this.orderDate,
    this.statusHistory = const [],
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.trackingNumber,
    this.deliveryNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'orderDate': orderDate.toIso8601String(),
      'statusHistory': statusHistory.map((h) => h.toMap()).toList(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'deliveryNote': deliveryNote,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      orderStatus: map['orderStatus'] ?? 'Pending',
      orderDate: _parseDateTime(map['orderDate']) ?? DateTime.now(),
      statusHistory:
          (map['statusHistory'] as List<dynamic>?)
              ?.map((h) => OrderStatusHistory.fromMap(h))
              .toList() ??
          [],
      confirmedAt: _parseDateTime(map['confirmedAt']),
      shippedAt: _parseDateTime(map['shippedAt']),
      deliveredAt: _parseDateTime(map['deliveredAt']),
      trackingNumber: map['trackingNumber'],
      deliveryNote: map['deliveryNote'],
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

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order.fromMap(data, doc.id);
  }
}
