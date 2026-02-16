import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../services/firestore_service.dart';
import '../../controllers/auth_controller.dart';
import 'ticket_detail_screen.dart';

class UserTicketsScreen extends StatelessWidget {
  const UserTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final firestoreService = Get.find<FirestoreService>();
    final userId = authController.firebaseUser.value?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Support Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getUserSupportTickets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green[700]!),
              ),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            debugPrint('❌ Ticket loading error: $error');

            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Setting up tickets...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check the console for a Firestore index link.',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Click the link to create the required index.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back),
                      label: Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'No Support Tickets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t submitted any tickets yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticketData = tickets[index];
              final ticket = SupportTicket.fromMap(ticketData);
              return _buildTicketCard(ticket);
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: ticket.hasUnreadReplies
            ? Border.all(color: Colors.green[700]!, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.to(() => TicketDetailScreen(ticketId: ticket.id));
          },
          child: Padding(
            padding: EdgeInsets.all(16),
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
                    if (ticket.hasUnreadReplies) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mark_email_unread,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'NEW REPLY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Spacer(),
                    Text(
                      'Ticket #${ticket.id.substring(ticket.id.length - 6)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  ticket.issue,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    SizedBox(width: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(ticket.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    if (ticket.replies.isNotEmpty) ...[
                      Spacer(),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${ticket.replies.length} ${ticket.replies.length == 1 ? 'reply' : 'replies'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
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
