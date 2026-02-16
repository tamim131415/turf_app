import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../models/order.dart' as app_models;
import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late OrderController orderController;
  final selectedFilter = 'All'.obs; // Make it reactive
  final TextEditingController searchController = TextEditingController();

  final List<String> statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize or get existing OrderController
    try {
      orderController = Get.find<OrderController>();
    } catch (e) {
      orderController = Get.put(OrderController());
    }
    // Load all orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadAllOrders();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<app_models.Order> getFilteredOrders() {
    List<app_models.Order> orders = orderController.allOrders;

    // Filter by search
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      orders = orders.where((order) {
        return order.id.toLowerCase().contains(query) ||
            order.customerName.toLowerCase().contains(query) ||
            order.phoneNumber.contains(query) ||
            order.email.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by status
    if (selectedFilter.value != 'All') {
      orders = orders
          .where((o) => o.orderStatus == selectedFilter.value)
          .toList();
    }

    // Sort by date (newest first)
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by order ID, customer name...',
                    prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Status Filter Chips
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusFilters.map((filter) {
                        final isSelected = selectedFilter.value == filter;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              selectedFilter.value = filter;
                            },
                            selectedColor: Colors.green[100],
                            checkmarkColor: Colors.green[700],
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]),
                );
              }

              final filteredOrders = getFilteredOrders();

              if (filteredOrders.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => orderController.loadAllOrders(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              selectedFilter.value == 'All'
                                  ? 'No Orders Yet'
                                  : 'No ${selectedFilter.value} Orders',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                orderController.loadAllOrders();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Refresh Orders'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => orderController.loadAllOrders(),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(app_models.Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    Color statusColor;
    IconData statusIcon;
    Color statusBgColor;

    switch (order.orderStatus) {
      case 'Pending':
        statusColor = Colors.orange[700]!;
        statusBgColor = Colors.orange[50]!;
        statusIcon = Icons.access_time;
        break;
      case 'Confirmed':
        statusColor = Colors.blue[700]!;
        statusBgColor = Colors.blue[50]!;
        statusIcon = Icons.check_circle;
        break;
      case 'Shipped':
        statusColor = Colors.purple[700]!;
        statusBgColor = Colors.purple[50]!;
        statusIcon = Icons.local_shipping;
        break;
      case 'Delivered':
        statusColor = Colors.green[700]!;
        statusBgColor = Colors.green[50]!;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Cancelled':
        statusColor = Colors.red[700]!;
        statusBgColor = Colors.red[50]!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey[50]!;
        statusIcon = Icons.info;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Get.to(() => OrderDetailScreen(order: order));
          // Refresh orders list if status was updated
          if (result == true) {
            setState(() {}); // Rebuild UI with updated orders
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(order.id.length - 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.orderDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          order.orderStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Divider(height: 24),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(order.phoneNumber, style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.address,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Divider(height: 24),

              // Order Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Text(
                    '৳${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
