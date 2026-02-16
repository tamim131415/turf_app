import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../services/firestore_service.dart';
import '../../controllers/auth_controller.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  final bool isAdmin;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    this.isAdmin = false,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final firestoreService = Get.find<FirestoreService>();
  final authController = Get.find<AuthController>();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Mark as read if user opens ticket
    if (!widget.isAdmin) {
      Future.delayed(Duration(milliseconds: 500), () {
        firestoreService.markTicketRepliesAsRead(widget.ticketId);
      });
    }
  }

  Future<void> _sendReply(SupportTicket ticket) async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await firestoreService.addTicketReply(
        ticketId: widget.ticketId,
        message: _replyController.text.trim(),
        isAdmin: widget.isAdmin,
        senderName: widget.isAdmin
            ? 'Support Team'
            : authController.userName.value,
      );

      _replyController.clear();

      // Scroll to bottom after reply
      Future.delayed(Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      Get.snackbar(
        'Success',
        'Reply sent successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reply',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await firestoreService.updateTicketStatus(widget.ticketId, status);
      Get.snackbar(
        'Success',
        'Status updated to ${status}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Ticket #${widget.ticketId.substring(widget.ticketId.length - 6)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        actions: widget.isAdmin
            ? [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: _updateStatus,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(Icons.pending, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Mark as Pending'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'in-progress',
                      child: Row(
                        children: [
                          Icon(Icons.autorenew, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Mark as In Progress'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'resolved',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Mark as Resolved'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'closed',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Mark as Closed'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: firestoreService.getSupportTicketStream(widget.ticketId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green[700]!),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Ticket not found'));
          }

          final ticket = SupportTicket.fromMap(snapshot.data!);

          return Column(
            children: [
              // Ticket Header
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              ticket.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(ticket.status),
                                size: 14,
                                color: _getStatusColor(ticket.status),
                              ),
                              SizedBox(width: 4),
                              Text(
                                ticket.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(ticket.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(ticket.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (widget.isAdmin) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.green[100],
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                ticket.userEmail,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.report_problem,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ticket.issue,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              // Conversation
              Expanded(
                child: ticket.replies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No replies yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: ticket.replies.length,
                        itemBuilder: (context, index) {
                          final reply = ticket.replies[index];
                          return _buildReplyBubble(reply);
                        },
                      ),
              ),

              // Reply Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type your reply...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Colors.green[700]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green[700],
                      child: _isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.send,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () => _sendReply(ticket),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    final isCurrentUser = widget.isAdmin == reply.isAdmin;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              reply.senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.green[700] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                reply.message,
                style: TextStyle(
                  fontSize: 14,
                  color: isCurrentUser ? Colors.white : Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, hh:mm a').format(reply.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'in-progress':
        return Icons.autorenew;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
