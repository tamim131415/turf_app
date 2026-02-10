import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';
import '../../utils/app_strings.dart';
import 'add_address_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController controller = Get.put(AddressController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myAddresses),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  'No Addresses Added',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add a delivery address to get started',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAddresses(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return _buildAddressCard(address, controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => AddAddressScreen());
        },
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          AppStrings.addAddress,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, AddressController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green[700]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              address.phoneNumber,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                if (!address.isDefault)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.setDefaultAddress(address.id);
                      },
                      icon: Icon(Icons.check_circle_outline, size: 18),
                      label: Text(AppStrings.setAsDefault),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                      ),
                    ),
                  ),
                if (!address.isDefault) SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => AddAddressScreen(address: address));
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: Text(AppStrings.edit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(address, controller);
                    },
                    icon: Icon(Icons.delete, size: 18),
                    label: Text(AppStrings.delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Address address, AddressController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.deleteAddress),
        content: Text(AppStrings.areYouSureDeleteAddress),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(address.id);
            },
            child: Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
