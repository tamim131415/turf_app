import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/payment_method_controller.dart';
import '../../models/address.dart';
import '../../models/payment_method.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/app_strings.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressFieldController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPaymentMethodType = 'Credit/Debit Card';
  Address? _selectedAddress;
  PaymentMethod? _selectedPaymentMethod;
  final AddressController _addressController = Get.put(AddressController());
  final PaymentMethodController _paymentMethodController = Get.put(
    PaymentMethodController(),
  );

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
    _loadDefaultPaymentMethod();
  }

  Future<void> _loadDefaultAddress() async {
    await _addressController.loadAddresses();
    final defaultAddr = _addressController.defaultAddress;
    if (defaultAddr != null) {
      setState(() {
        _selectedAddress = defaultAddr;
        _nameController.text = defaultAddr.name;
        _addressFieldController.text = defaultAddr.fullAddress;
        _phoneController.text = defaultAddr.phoneNumber;
      });
    }
  }

  Future<void> _loadDefaultPaymentMethod() async {
    await _paymentMethodController.loadPaymentMethods();
    final defaultPayment = _paymentMethodController.defaultPaymentMethod;
    if (defaultPayment != null) {
      setState(() {
        _selectedPaymentMethod = defaultPayment;
        _selectedPaymentMethodType = defaultPayment.type;
      });
    }
  }

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
      _nameController.text = address.name;
      _addressFieldController.text = address.fullAddress;
      _phoneController.text = address.phoneNumber;
    });
    Get.back();
  }

  void _showAddressSelector() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.addAddress)?.then((_) {
                        _loadDefaultAddress();
                      });
                    },
                    child: Text('+ Add New'),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (_addressController.addresses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(AppStrings.noSavedAddresses),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(Routes.addAddress)?.then((_) {
                                _loadDefaultAddress();
                              });
                            },
                            child: Text(AppStrings.addAddressButton),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _addressController.addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addressController.addresses[index];
                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.green[700],
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(address.name)),
                          if (address.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.phoneNumber),
                          Text(
                            address.fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _selectAddress(address),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _selectPaymentMethod(PaymentMethod paymentMethod) {
    setState(() {
      _selectedPaymentMethod = paymentMethod;
      _selectedPaymentMethodType = paymentMethod.type;
    });
    Get.back();
  }

  void _showPaymentMethodSelector() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.addPaymentMethod)?.then((_) {
                        _loadDefaultPaymentMethod();
                      });
                    },
                    child: Text('+ Add New'),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (_paymentMethodController.paymentMethods.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(AppStrings.noSavedPaymentMethods),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(Routes.addPaymentMethod)?.then((_) {
                                _loadDefaultPaymentMethod();
                              });
                            },
                            child: Text(AppStrings.addPaymentMethodButton),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _paymentMethodController.paymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod =
                        _paymentMethodController.paymentMethods[index];
                    return ListTile(
                      leading: Icon(
                        _getPaymentIcon(paymentMethod.type),
                        color: Colors.green[700],
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(paymentMethod.displayName)),
                          if (paymentMethod.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
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
                      onTap: () => _selectPaymentMethod(paymentMethod),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.checkout,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedAddress != null
                                        ? 'Selected Address'
                                        : 'No Address Selected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showAddressSelector,
                                    icon: Icon(Icons.location_on),
                                    label: Text('Change'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _addressFieldController,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedPaymentMethod != null
                                        ? 'Selected Payment'
                                        : 'No Payment Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showPaymentMethodSelector,
                                    icon: Icon(Icons.payment),
                                    label: Text('Change'),
                                  ),
                                ],
                              ),
                              if (_selectedPaymentMethod != null) ...[
                                SizedBox(height: 12),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[50],
                                    child: Icon(
                                      _getPaymentIcon(
                                        _selectedPaymentMethod!.type,
                                      ),
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  title: Text(
                                    _selectedPaymentMethod!.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _selectedPaymentMethod!.displayDetail,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Obx(
                                () => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Items (${controller.cartItems.length}):',
                                    ),
                                    Text(
                                      '৳${controller.cartTotal.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppStrings.shipping),
                                  Text(AppStrings.shippingAmount),
                                ],
                              ),
                              Divider(),
                              Obx(
                                () => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '৳${(controller.cartTotal + 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    onPressed: controller.cartItems.isEmpty
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final orderId = await controller.placeOrder(
                                  customerName: _nameController.text,
                                  phoneNumber: _phoneController.text,
                                  email:
                                      authController
                                          .firebaseUser
                                          .value
                                          ?.email ??
                                      '',
                                  address: _addressFieldController.text,
                                  paymentMethod: _selectedPaymentMethodType,
                                );
                                if (orderId != null) {
                                  Get.toNamed(
                                    Routes.orderSuccess,
                                    arguments: orderId,
                                  );
                                }
                              } catch (e) {
                                // Error is handled in controller
                              }
                            }
                          },
                    child: Text(
                      'PLACE ORDER - ৳${(controller.cartTotal + 100).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
