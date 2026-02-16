import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String issue;
  final String status; // 'pending', 'in-progress', 'resolved', 'closed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketReply> replies;
  final bool hasUnreadReplies; // For user to see if admin replied

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.issue,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.replies = const [],
    this.hasUnreadReplies = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'issue': issue,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'replies': replies.map((r) => r.toMap()).toList(),
      'hasUnreadReplies': hasUnreadReplies,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      issue: map['issue'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      replies:
          (map['replies'] as List<dynamic>?)
              ?.map((r) => TicketReply.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      hasUnreadReplies: map['hasUnreadReplies'] ?? false,
    );
  }

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? issue,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TicketReply>? replies,
    bool? hasUnreadReplies,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      issue: issue ?? this.issue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
      hasUnreadReplies: hasUnreadReplies ?? this.hasUnreadReplies,
    );
  }
}

class TicketReply {
  final String id;
  final String message;
  final bool isAdmin;
  final String senderName;
  final DateTime createdAt;

  TicketReply({
    required this.id,
    required this.message,
    required this.isAdmin,
    required this.senderName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isAdmin': isAdmin,
      'senderName': senderName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TicketReply.fromMap(Map<String, dynamic> map) {
    return TicketReply(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      senderName: map['senderName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
