import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_method_controller.dart';
import '../../services/auth_service.dart';
import '../../models/payment_method.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentMethodController controller =
      Get.find<PaymentMethodController>();
  final AuthService authService = Get.find<AuthService>();

  final PaymentMethod? paymentMethod = Get.arguments as PaymentMethod?;

  late String _selectedType;
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  String _selectedMobileProvider = 'bKash';
  bool _isDefault = false;

  final List<String> _paymentTypes = [
    'Card',
    'Mobile Banking',
    'Cash on Delivery',
  ];

  final List<String> _mobileProviders = ['bKash', 'Nagad', 'Rocket', 'Upay'];

  @override
  void initState() {
    super.initState();
    _selectedType = paymentMethod?.type ?? 'Card';
    if (paymentMethod != null) {
      _cardHolderNameController.text = paymentMethod!.cardHolderName ?? '';
      _cardNumberController.text = paymentMethod!.cardNumberLast4 ?? '';
      _expiryController.text = paymentMethod!.expiryDate ?? '';
      _mobileNumberController.text = paymentMethod!.mobileNumberLast4 ?? '';
      _selectedMobileProvider = paymentMethod!.mobileProvider ?? 'bKash';
      _isDefault = paymentMethod!.isDefault;
    }
  }

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          paymentMethod == null ? 'Add Payment Method' : 'Edit Payment Method',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Payment Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _paymentTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedType == 'Card') _buildCardForm(),
            if (_selectedType == 'Mobile Banking') _buildMobileBankingForm(),
            if (_selectedType == 'Cash on Delivery') _buildCashOnDeliveryForm(),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Set as default payment method'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _savePaymentMethod,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        paymentMethod == null
                            ? 'Add Payment Method'
                            : 'Update Payment Method',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _cardHolderNameController,
          decoration: InputDecoration(
            labelText: 'Card Holder Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
            hintText: '**** **** **** 1234',
          ),
          keyboardType: TextInputType.number,
          maxLength: 19,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            // For edit mode, we only store last 4 digits
            if (paymentMethod == null &&
                value.replaceAll(' ', '').length < 13) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.datetime,
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Format: MM/YY';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
                validator: (value) {
                  if (paymentMethod == null &&
                      (value == null || value.length != 3)) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileBankingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedMobileProvider,
          decoration: InputDecoration(
            labelText: 'Mobile Banking Provider',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          items: _mobileProviders.map((provider) {
            return DropdownMenuItem(value: provider, child: Text(provider));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMobileProvider = value!;
            });
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _mobileNumberController,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '01XXX-XXXXXX',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter mobile number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCashOnDeliveryForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.money, size: 64, color: Colors.green[700]),
            SizedBox(height: 16),
            Text(
              'Cash on Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Pay with cash when your order is delivered',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      final userId = authService.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      String? cardNumberLast4;
      String? mobileNumberLast4;

      if (_selectedType == 'Card') {
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        cardNumberLast4 = paymentMethod != null
            ? _cardNumberController.text
            : cardNumber.substring(cardNumber.length - 4);
      } else if (_selectedType == 'Mobile Banking') {
        final mobileNumber = _mobileNumberController.text.replaceAll('-', '');
        mobileNumberLast4 = paymentMethod != null
            ? _mobileNumberController.text
            : mobileNumber.substring(mobileNumber.length - 4);
      }

      final newPaymentMethod = PaymentMethod(
        id: paymentMethod?.id ?? 'pm_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: _selectedType,
        cardHolderName: _selectedType == 'Card'
            ? _cardHolderNameController.text
            : null,
        cardNumberLast4: cardNumberLast4,
        expiryDate: _selectedType == 'Card' ? _expiryController.text : null,
        mobileProvider: _selectedType == 'Mobile Banking'
            ? _selectedMobileProvider
            : null,
        mobileNumberLast4: mobileNumberLast4,
        isDefault: _isDefault,
      );

      if (paymentMethod == null) {
        controller.addPaymentMethod(newPaymentMethod);
      } else {
        controller.updatePaymentMethod(newPaymentMethod);
      }
    }
  }
}
