import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../services/cloudinary_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductController productController = Get.find<ProductController>();
  final CloudinaryService cloudinaryService = Get.find<CloudinaryService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController reviewCountController = TextEditingController(
    text: '0',
  );

  String selectedCategory = 'Jerseys';
  String selectedBrand = 'Nike';
  String selectedTeam = 'Argentina';
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isUploading = false;
  double rating = 4.0;
  List<String> selectedSizes = ['S', 'M', 'L', 'XL'];

  final List<String> categories = [
    'Jerseys',
    'Shoes',
    'Balls',
    'Accessories',
    'Training',
    'Others',
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

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    descriptionController.dispose();
    reviewCountController.dispose();
    super.dispose();
  }

  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

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

  Future<void> _addProduct() async {
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

    if (selectedSizes.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one size',
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
      int reviewCount = int.parse(reviewCountController.text);
      String productId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

      // Default image URL
      String finalImageUrl =
          'https://via.placeholder.com/300x400/cccccc/666666?text=Product+Image';

      // Upload to Cloudinary CDN by default
      if (selectedImage != null) {
        String? cloudinaryImageUrl = await cloudinaryService.uploadProductImage(
          selectedImage!,
          productId,
        );

        if (cloudinaryImageUrl != null) {
          finalImageUrl = cloudinaryImageUrl;
        } else {
          Get.snackbar(
            'Warning',
            'Image upload failed, using default image',
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[800],
            snackPosition: SnackPosition.TOP,
          );
        }
      }

      // Create new product
      Product newProduct = Product(
        id: productId,
        name: nameController.text,
        price: price,
        originalPrice: originalPrice,
        team: selectedTeam,
        category: selectedCategory,
        brand: selectedBrand,
        imageUrl: finalImageUrl,
        rating: rating,
        reviewCount: reviewCount,
        isFavorite: false,
        sizes: selectedSizes,
        colors: [Colors.green, Colors.white],
        description: descriptionController.text.isEmpty
            ? 'Custom added product'
            : descriptionController.text,
      );

      // Add product using the controller
      await productController.addProduct(newProduct);

      // Close any open dialogs
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      // Navigate back first
      Get.back();

      // Then show success message
      Get.snackbar(
        'Success',
        'Product added successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      // Close any open dialogs
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to add product: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.sports_soccer),
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

              // Team Dropdown
              DropdownButtonFormField<String>(
                value: selectedTeam,
                decoration: InputDecoration(
                  labelText: 'Team',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.groups),
                ),
                items: teams.map((String team) {
                  return DropdownMenuItem<String>(
                    value: team,
                    child: Text(team),
                  );
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

              // Rating Slider
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange[700]),
                        SizedBox(width: 8),
                        Text(
                          'Rating: ${rating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: rating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: rating.toStringAsFixed(1),
                      activeColor: Colors.orange[700],
                      onChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Review Count
              TextField(
                controller: reviewCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Review Count',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.reviews),
                ),
              ),
              SizedBox(height: 16),

              // Sizes Selection
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.straighten, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Available Sizes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
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
                          checkmarkColor: Colors.green[700],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Image Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Product Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    if (selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _pickImageFromGallery,
                            icon: Icon(Icons.photo_library),
                            label: Text('Gallery'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _pickImageFromCamera,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Description
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 24),

              // Add Product Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isUploading ? null : _addProduct,
                  child: isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Adding Product...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 8),
                            Text(
                              'Add Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    );
  }
}
