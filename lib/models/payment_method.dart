import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String userId;
  final String type; // 'Card', 'Mobile Banking', 'Cash on Delivery'
  final String? cardHolderName;
  final String? cardNumberLast4; // Last 4 digits for security
  final String? expiryDate; // MM/YY format
  final String? mobileProvider; // bKash, Nagad, Rocket, etc.
  final String? mobileNumberLast4; // Last 4 digits
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.cardHolderName,
    this.cardNumberLast4,
    this.expiryDate,
    this.mobileProvider,
    this.mobileNumberLast4,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'cardHolderName': cardHolderName,
      'cardNumberLast4': cardNumberLast4,
      'expiryDate': expiryDate,
      'mobileProvider': mobileProvider,
      'mobileNumberLast4': mobileNumberLast4,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      cardHolderName: map['cardHolderName'],
      cardNumberLast4: map['cardNumberLast4'],
      expiryDate: map['expiryDate'],
      mobileProvider: map['mobileProvider'],
      mobileNumberLast4: map['mobileNumberLast4'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  factory PaymentMethod.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethod.fromMap(data);
  }

  String get displayName {
    switch (type) {
      case 'Card':
        return '$cardHolderName - **** $cardNumberLast4';
      case 'Mobile Banking':
        return '$mobileProvider - **** $mobileNumberLast4';
      case 'Cash on Delivery':
        return 'Cash on Delivery';
      default:
        return type;
    }
  }

  String get displayDetail {
    switch (type) {
      case 'Card':
        return 'Expires: $expiryDate';
      case 'Mobile Banking':
        return mobileProvider ?? '';
      case 'Cash on Delivery':
        return 'Pay when you receive';
      default:
        return '';
    }
  }

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? type,
    String? cardHolderName,
    String? cardNumberLast4,
    String? expiryDate,
    String? mobileProvider,
    String? mobileNumberLast4,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumberLast4: cardNumberLast4 ?? this.cardNumberLast4,
      expiryDate: expiryDate ?? this.expiryDate,
      mobileProvider: mobileProvider ?? this.mobileProvider,
      mobileNumberLast4: mobileNumberLast4 ?? this.mobileNumberLast4,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
