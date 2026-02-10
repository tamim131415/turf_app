import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_method_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/app_strings.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final PaymentMethodController controller = Get.put(PaymentMethodController());

  PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.paymentMethods), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value && controller.paymentMethods.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No payment methods added yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.addPaymentMethod),
                  icon: Icon(Icons.add),
                  label: Text(AppStrings.addPaymentMethod),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadPaymentMethods,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.paymentMethods.length,
            itemBuilder: (context, index) {
              final paymentMethod = controller.paymentMethods[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[50],
                    child: Icon(
                      _getPaymentIcon(paymentMethod.type),
                      color: Colors.green[700],
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          paymentMethod.displayName,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (paymentMethod.isDefault)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(paymentMethod.displayDetail),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      if (!paymentMethod.isDefault)
                        PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text(AppStrings.setAsDefault),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text(AppStrings.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.delete,
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'default':
                          controller.setDefaultPaymentMethod(paymentMethod.id);
                          break;
                        case 'edit':
                          Get.toNamed(
                            Routes.addPaymentMethod,
                            arguments: paymentMethod,
                          );
                          break;
                        case 'delete':
                          _showDeleteDialog(context, paymentMethod.id);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(
        () => controller.paymentMethods.isEmpty
            ? SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => Get.toNamed(Routes.addPaymentMethod),
                icon: Icon(Icons.add),
                label: Text(AppStrings.addPayment),
              ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'Card':
        return Icons.credit_card;
      case 'Mobile Banking':
        return Icons.phone_android;
      case 'Cash on Delivery':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _showDeleteDialog(BuildContext context, String paymentMethodId) {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.deletePaymentMethod),
        content: Text(AppStrings.areYouSureDeletePaymentMethod),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePaymentMethod(paymentMethodId);
            },
            child: Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
