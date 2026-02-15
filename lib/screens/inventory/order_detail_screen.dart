import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order.dart' as app_models;
import '../../models/order_status_history.dart';

class OrderDetailScreen extends StatefulWidget {
  final app_models.Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            SizedBox(height: 8),
            _buildCustomerInfo(),
            SizedBox(height: 8),
            _buildOrderItems(),
            SizedBox(height: 8),
            _buildPaymentInfo(),
            SizedBox(height: 8),
            if (_isAdmin()) _buildStatusUpdateSection(),
            if (_isAdmin()) SizedBox(height: 8),
            _buildStatusTimeline(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    Color statusColor;
    Color statusBgColor;

    switch (widget.order.orderStatus) {
      case 'Pending':
        statusColor = Colors.orange[700]!;
        statusBgColor = Colors.orange[50]!;
        break;
      case 'Confirmed':
        statusColor = Colors.blue[700]!;
        statusBgColor = Colors.blue[50]!;
        break;
      case 'Shipped':
        statusColor = Colors.purple[700]!;
        statusBgColor = Colors.purple[50]!;
        break;
      case 'Delivered':
        statusColor = Colors.green[700]!;
        statusBgColor = Colors.green[50]!;
        break;
      case 'Cancelled':
        statusColor = Colors.red[700]!;
        statusBgColor = Colors.red[50]!;
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey[50]!;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '#${widget.order.id}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                DateFormat(
                  'MMM dd, yyyy - hh:mm a',
                ).format(widget.order.orderDate),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 12, color: statusColor),
                SizedBox(width: 8),
                Text(
                  'Status: ${widget.order.orderStatus}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),
          _buildInfoRow(Icons.person, 'Name', widget.order.customerName),
          SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Phone', widget.order.phoneNumber),
          SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', widget.order.email),
          SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Address', widget.order.address),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${widget.order.items.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),
          ...widget.order.items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[500]),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                widget.order.paymentMethod,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                '৳${(widget.order.totalAmount - 100).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Charge',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text('৳100.00', style: TextStyle(fontSize: 14)),
            ],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '৳${widget.order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),

          // Status Action Buttons
          Wrap(spacing: 8, runSpacing: 8, children: _buildStatusButtons()),

          SizedBox(height: 16),

          // Tracking Number Field
          if (widget.order.orderStatus == 'Confirmed')
            Column(
              children: [
                TextField(
                  controller: _trackingController,
                  decoration: InputDecoration(
                    labelText: 'Tracking Number (Optional)',
                    hintText: 'Enter tracking number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.qr_code, color: Colors.green[700]),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),

          // Note Field
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Add Note (Optional)',
              hintText: 'e.g., Delivery scheduled for tomorrow',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.note, color: Colors.green[700]),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusButtons() {
    List<Widget> buttons = [];

    if (widget.order.orderStatus == 'Pending') {
      buttons.add(
        _buildStatusButton(
          'Confirm Order',
          'Confirmed',
          Colors.blue,
          Icons.check_circle,
        ),
      );
    }

    if (widget.order.orderStatus == 'Confirmed') {
      buttons.add(
        _buildStatusButton(
          'Mark as Shipped',
          'Shipped',
          Colors.purple,
          Icons.local_shipping,
        ),
      );
    }

    if (widget.order.orderStatus == 'Shipped') {
      buttons.add(
        _buildStatusButton(
          'Mark as Delivered',
          'Delivered',
          Colors.green,
          Icons.check_circle_outline,
        ),
      );
    }

    if (widget.order.orderStatus != 'Delivered' &&
        widget.order.orderStatus != 'Cancelled') {
      buttons.add(
        _buildStatusButton(
          'Cancel Order',
          'Cancelled',
          Colors.red,
          Icons.cancel,
        ),
      );
    }

    return buttons;
  }

  Widget _buildStatusButton(
    String label,
    String status,
    Color color,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _showConfirmDialog(status),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showConfirmDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: Text(
          'Are you sure you want to change status to "$newStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green[700]),
                SizedBox(height: 16),
                Text('Updating order status...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final adminEmail = authController.firebaseUser.value?.email ?? 'Admin';

      await orderController.updateOrderStatus(
        orderId: widget.order.id,
        newStatus: newStatus,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        trackingNumber: _trackingController.text.isNotEmpty
            ? _trackingController.text
            : null,
        updatedBy: adminEmail,
      );

      // Wait for orders to reload
      await orderController.loadAllOrders();

      // Close loading dialog
      Get.back();

      // Clear inputs
      _noteController.clear();
      _trackingController.clear();

      // Show success and go back
      Get.snackbar(
        '✅ Success',
        'Order status changed to "$newStatus" successfully!',
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      // Go back to orders list
      await Future.delayed(Duration(milliseconds: 500));
      Get.back(result: true);
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        '❌ Error',
        'Failed to update: $e',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Widget _buildStatusTimeline() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 16),

          if (widget.order.statusHistory.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No status history available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...widget.order.statusHistory.map((history) {
              return _buildTimelineItem(history);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(OrderStatusHistory history) {
    Color statusColor;
    IconData statusIcon;

    switch (history.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'Shipped':
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case 'Delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    bool isLast = widget.order.statusHistory.last == history;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey[300]),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(history.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (history.note != null && history.note!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    history.note!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
                SizedBox(height: 4),
                Text(
                  'By: ${history.updatedBy}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isAdmin() {
    final userEmail = authController.firebaseUser.value?.email ?? '';
    return userEmail == 'admin@turfmate.com';
  }
}
