import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../services/cloudinary_service.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  final ProductController productController = Get.find<ProductController>();
  final CloudinaryService cloudinaryService = Get.find<CloudinaryService>();

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController originalPriceController;
  late TextEditingController descriptionController;
  late TextEditingController reviewCountController;
  late TextEditingController quantityController;

  late String selectedCategory;
  late String selectedBrand;
  late String selectedTeam;
  File? selectedImage;
  String? existingImageUrl;
  final ImagePicker picker = ImagePicker();
  bool isUploading = false;
  late double rating;
  late List<String> selectedSizes;

  late Product product;

  final List<String> categories = [
    'Jerseys',
    'Shoes',
    'Balls',
    'Accessories',
    'Training',
  ];

  final List<String> brands = [
    'Nike',
    'Adidas',
    'Puma',
    'New Balance',
    'Others',
  ];

  final List<String> teams = [
    'Argentina',
    'Brazil',
    'Germany',
    'France',
    'Spain',
    'England',
    'Others',
  ];

  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    product = Get.arguments as Product;

    // Initialize controllers with product data
    nameController = TextEditingController(text: product.name);
    priceController = TextEditingController(text: product.price.toString());
    originalPriceController = TextEditingController(
      text: product.originalPrice?.toString() ?? '',
    );
    descriptionController = TextEditingController(text: product.description);
    reviewCountController = TextEditingController(
      text: product.reviewCount.toString(),
    );
    quantityController = TextEditingController(
      text: product.quantity.toString(),
    );

    selectedCategory = product.category;
    selectedBrand = product.brand;
    selectedTeam = product.team;
    rating = product.rating;
    selectedSizes = List.from(product.sizes);
    existingImageUrl = product.imageUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    descriptionController.dispose();
    reviewCountController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _updateProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in product name and price',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (quantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the stock quantity',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Only validate sizes for Jerseys and Shoes
    if ((selectedCategory == 'Jerseys' || selectedCategory == 'Shoes') &&
        selectedSizes.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one size for ${selectedCategory.toLowerCase()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      setState(() {
        isUploading = true;
      });

      double price = double.parse(priceController.text);
      double? originalPrice;
      if (originalPriceController.text.isNotEmpty) {
        originalPrice = double.parse(originalPriceController.text);
      }

      int quantity = int.parse(quantityController.text);
      int reviewCount = int.parse(reviewCountController.text);

      String finalImageUrl = existingImageUrl ?? '';

      // Upload new image if selected
      if (selectedImage != null) {
        String? cloudinaryImageUrl = await cloudinaryService.uploadProductImage(
          selectedImage!,
          product.id,
        );

        if (cloudinaryImageUrl != null) {
          finalImageUrl = cloudinaryImageUrl;
        } else {
          Get.snackbar(
            'Warning',
            'Image upload failed, keeping existing image',
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[800],
            snackPosition: SnackPosition.TOP,
          );
        }
      }

      // Create updated product
      Product updatedProduct = Product(
        id: product.id,
        name: nameController.text,
        price: price,
        originalPrice: originalPrice,
        team: selectedTeam,
        category: selectedCategory,
        brand: selectedBrand,
        imageUrl: finalImageUrl,
        rating: rating,
        reviewCount: reviewCount,
        isFavorite: product.isFavorite,
        sizes: (selectedCategory == 'Jerseys' || selectedCategory == 'Shoes')
            ? selectedSizes
            : [],
        colors: [Colors.green, Colors.white],
        description: descriptionController.text.isEmpty
            ? 'Product description'
            : descriptionController.text,
        quantity: quantity,
      );

      // Update product using the controller
      await productController.updateProduct(updatedProduct);

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      // Navigate back
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Product updated successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to update product: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Product',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selection
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromGallery();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Take a Photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromCamera();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        )
                      : existingImageUrl != null && existingImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            existingImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to change image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add product image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Product Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            SizedBox(height: 16),

            // Price
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (৳)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            SizedBox(height: 16),

            // Original Price (Optional)
            TextField(
              controller: originalPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Original Price (৳) - Optional',
                hintText: 'For showing discounts',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.money_off),
              ),
            ),
            SizedBox(height: 16),

            // Quantity
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity *',
                hintText: 'Available stock quantity',
                helperText: 'Enter the number of items in stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.inventory_2, color: Colors.green[700]),
              ),
            ),
            SizedBox(height: 16),

            // Team Dropdown
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: selectedTeam,
              decoration: InputDecoration(
                labelText: 'Team',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.groups),
              ),
              items: teams.map((String team) {
                return DropdownMenuItem<String>(value: team, child: Text(team));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Brand Dropdown
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: selectedBrand,
              decoration: InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.branding_watermark),
              ),
              items: brands.map((String brand) {
                return DropdownMenuItem<String>(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedBrand = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Sizes Selection (Only for Jerseys and Shoes)
            if (selectedCategory == 'Jerseys' ||
                selectedCategory == 'Shoes') ...[
              Text(
                'Available Sizes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableSizes.map((size) {
                  final isSelected = selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedSizes.add(size);
                        } else {
                          selectedSizes.remove(size);
                        }
                      });
                    },
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green[800],
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],

            // Rating
            Text(
              'Rating: ${rating.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Slider(
              value: rating,
              min: 0,
              max: 5,
              divisions: 10,
              label: rating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
              activeColor: Colors.green[700],
            ),
            SizedBox(height: 16),

            // Reviews Count
            TextField(
              controller: reviewCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Reviews',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.rate_review),
              ),
            ),
            SizedBox(height: 16),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Product Description',
                hintText: 'Enter product details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 32),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                onPressed: isUploading ? null : _updateProduct,
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'UPDATE PRODUCT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
