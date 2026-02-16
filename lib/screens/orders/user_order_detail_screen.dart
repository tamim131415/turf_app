import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/order.dart' as app_models;
import '../../models/review.dart';
import '../../services/firestore_service.dart';

class UserOrderDetailScreen extends StatefulWidget {
  final app_models.Order order;

  const UserOrderDetailScreen({super.key, required this.order});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();
  final FirestoreService firestoreService = Get.find<FirestoreService>();

  // Review form controllers (one per product)
  Map<String, TextEditingController> reviewControllers = {};
  Map<String, double> reviewRatings = {};
  Map<String, bool> hasReviewed = {};
  bool isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each product
    for (var item in widget.order.items) {
      reviewControllers[item.product.id] = TextEditingController();
      reviewRatings[item.product.id] = 5.0;
      hasReviewed[item.product.id] = false;
    }
    _checkExistingReviews();
  }

  Future<void> _checkExistingReviews() async {
    setState(() {
      isLoadingReviews = true;
    });

    for (var item in widget.order.items) {
      final review = await firestoreService.getReviewByOrderAndProduct(
        widget.order.id,
        item.product.id,
      );
      if (review != null) {
        hasReviewed[item.product.id] = true;
      }
    }

    setState(() {
      isLoadingReviews = false;
    });
  }

  @override
  void dispose() {
    for (final controller in reviewControllers.values) {
      controller.dispose();
    }
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
            _buildStatusTimeline(),
            if (widget.order.orderStatus == 'Delivered') ...[
              SizedBox(height: 8),
              _buildReviewSection(),
            ],
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
            'Order #${widget.order.id}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                DateFormat(
                  'MMM dd, yyyy - hh:mm a',
                ).format(widget.order.orderDate),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.order.orderStatus,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
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
            'Delivery Information',
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
          if (widget.order.trackingNumber != null) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.local_shipping,
              'Tracking Number',
              widget.order.trackingNumber!,
            ),
          ],
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
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
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
            'Order Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),
          ...widget.order.items.map((item) {
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '৳${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' × ${item.quantity}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            );
          }),
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
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          Divider(height: 24),
          _buildPriceRow('Subtotal', widget.order.totalAmount - 100),
          SizedBox(height: 8),
          _buildPriceRow('Delivery Charge', 100),
          Divider(height: 24),
          _buildPriceRow(
            'Total Amount',
            widget.order.totalAmount,
            isTotal: true,
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.payment, color: Colors.green[700]),
                SizedBox(width: 12),
                Text(
                  'Payment: ${widget.order.paymentMethod}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[isTotal ? 800 : 600],
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.green[700] : Colors.grey[800],
          ),
        ),
      ],
    );
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
          Divider(height: 24),
          ...widget.order.statusHistory.map((history) {
            return _buildTimelineItem(
              history.status,
              history.timestamp,
              history.note,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String status, DateTime timestamp, String? note) {
    IconData icon;
    Color color;

    switch (status) {
      case 'Pending':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'Confirmed':
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;
      case 'Shipped':
        icon = Icons.local_shipping;
        color = Colors.purple;
        break;
      case 'Delivered':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (note != null && note.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange[700]),
              SizedBox(width: 8),
              Text(
                'Rate Your Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your feedback helps other customers!',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Divider(height: 24),
          if (isLoadingReviews)
            Center(child: CircularProgressIndicator())
          else
            ...widget.order.items.map((item) {
              return _buildProductReviewCard(item);
            }),
        ],
      ),
    );
  }

  Widget _buildProductReviewCard(dynamic item) {
    final productId = item.product.id;
    final alreadyReviewed = hasReviewed[productId] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (alreadyReviewed)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'You have already reviewed this product',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Rating Stars
              Row(
                children: [
                  Text(
                    'Your Rating: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ...List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < (reviewRatings[productId] ?? 5)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange[700],
                      ),
                      onPressed: () {
                        setState(() {
                          reviewRatings[productId] = (index + 1).toDouble();
                        });
                      },
                    );
                  }),
                  Text(
                    '${reviewRatings[productId]?.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Review Comment
              TextField(
                controller: reviewControllers[productId],
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.comment, color: Colors.green[700]),
                ),
              ),
              SizedBox(height: 12),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _submitReview(item),
                  icon: Icon(Icons.send),
                  label: Text('Submit Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(dynamic item) async {
    final productId = item.product.id;
    final rating = reviewRatings[productId] ?? 5.0;
    final comment = reviewControllers[productId]?.text ?? '';

    debugPrint('🔍 Debug Review Submission:');
    debugPrint('  Item: $item');
    debugPrint('  Product: ${item.product}');
    debugPrint('  Product ID: "$productId"');
    debugPrint('  Product Name: ${item.product.name}');
    debugPrint('  Rating: $rating');
    debugPrint('  Comment length: ${comment.length}');

    if (comment.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please write a comment for your review',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      color: Colors.green[700],
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Submitting Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final user = authController.firebaseUser.value;
      final review = Review(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        userId: user?.uid ?? '',
        userName:
            user?.displayName ?? user?.email?.split('@')[0] ?? 'Anonymous',
        orderId: widget.order.id,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        isVerifiedPurchase: true,
      );

      debugPrint(
        '📝 Submitting review for product: $productId with rating: $rating',
      );
      await firestoreService.saveReview(review);
      debugPrint('✅ Review submission completed');

      // Wait a moment for Firestore to update
      debugPrint('⏳ Waiting for Firestore update...');
      await Future.delayed(Duration(milliseconds: 500));

      // Reload products to update ratings on home screen
      debugPrint('🔄 Reloading products...');
      productController.loadProducts();

      // Wait for products to reload
      await Future.delayed(Duration(seconds: 1));
      debugPrint('✅ Products reload triggered');

      // Close loading dialog
      Get.back();

      setState(() {
        hasReviewed[productId] = true;
      });

      Get.snackbar(
        '✅ Success',
        'Your review has been submitted successfully!',
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        '❌ Error',
        'Failed to submit review: $e',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
}
