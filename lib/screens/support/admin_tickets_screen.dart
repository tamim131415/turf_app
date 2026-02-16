import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../services/firestore_service.dart';
import 'ticket_detail_screen.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final firestoreService = Get.find<FirestoreService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Support Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in-progress'),
                  SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved'),
                  SizedBox(width: 8),
                  _buildFilterChip('Closed', 'closed'),
                ],
              ),
            ),
          ),
          Divider(height: 1),

          // Tickets List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.getAllSupportTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.green[700]!),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading tickets',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var tickets = snapshot.data ?? [];

                // Filter tickets
                if (selectedFilter != 'all') {
                  tickets = tickets
                      .where((t) => t['status'] == selectedFilter)
                      .toList();
                }

                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          'No Tickets Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          selectedFilter == 'all'
                              ? 'No support tickets submitted yet'
                              : 'No tickets with ${selectedFilter} status',
                          style: TextStyle(color: Colors.grey[500]),
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
                    return _buildAdminTicketCard(ticket);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      selectedColor: Colors.green[700],
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildAdminTicketCard(SupportTicket ticket) {
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.to(
              () => TicketDetailScreen(ticketId: ticket.id, isAdmin: true),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green[100],
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
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
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      child: Text(
                        ticket.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(ticket.status),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  ticket.issue,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
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
                if (ticket.status == 'pending') ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Awaiting response',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
}
