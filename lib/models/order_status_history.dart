import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusHistory {
  final String status;
  final DateTime timestamp;
  final String updatedBy;
  final String? note;

  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    required this.updatedBy,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'updatedBy': updatedBy,
      'note': note,
    };
  }

  factory OrderStatusHistory.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistory(
      status: map['status'] ?? '',
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      updatedBy: map['updatedBy'] ?? '',
      note: map['note'],
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
}
