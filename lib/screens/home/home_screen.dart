import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../app/routes/app_routes.dart';
import '../../services/firebase_connection_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController productController = Get.find<ProductController>();
  final int _currentIndex = 0;

  final List<String> _categories = [
    'All',
    'Jerseys',
    'Shoes',
    'Accessories',
    'Balls',
    'Training',
  ];

  final TextEditingController _searchController = TextEditingController();
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _filteredProducts.value = productController.products;
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    _searchQuery.value = query;

    if (query.isEmpty) {
      _filteredProducts.value = productController.filteredProducts;
    } else {
      _filteredProducts.value = productController.filteredProducts.where((
        product,
      ) {
        final nameMatch = product.name.toLowerCase().contains(query);
        final teamMatch = product.team.toLowerCase().contains(query);
        final categoryMatch = product.category.toLowerCase().contains(query);
        return nameMatch || teamMatch || categoryMatch;
      }).toList();
    }
  }

  void _filterByCategory(String category) {
    productController.filterByCategory(category);
    _filterProducts(); // Re-apply search filter if any
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenContent();
  }
}

// Content widget that can be used in MainNavigationScreen
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final ProductController productController = Get.find<ProductController>();

  final List<String> _categories = [
    'All',
    'Jerseys',
    'Shoes',
    'Accessories',
    'Balls',
    'Training',
  ];

  final TextEditingController _searchController = TextEditingController();
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _filteredProducts.value = productController.products;
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    _searchQuery.value = query;

    if (query.isEmpty) {
      _filteredProducts.value = productController.filteredProducts;
    } else {
      _filteredProducts.value = productController.filteredProducts.where((
        product,
      ) {
        final nameMatch = product.name.toLowerCase().contains(query);
        final teamMatch = product.team.toLowerCase().contains(query);
        final categoryMatch = product.category.toLowerCase().contains(query);
        return nameMatch || teamMatch || categoryMatch;
      }).toList();
    }
  }

  void _filterByCategory(String category) {
    productController.filterByCategory(category);
    _filterProducts(); // Re-apply search filter if any
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Turf-Mate',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Connection Status Indicator
          Obx(
            () => Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: productController.isOnline.value
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    productController.isOnline.value
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    productController.isOnline.value ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add Product Button
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.green[700]),
            onPressed: () {
              Get.toNamed(Routes.ADD_PRODUCT);
            },
            tooltip: 'Add Product',
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.grey[700]),
                Obx(() {
                  final count = productController.cartItems.length;
                  if (count > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
            onPressed: () {
              Get.toNamed(Routes.CART);
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey[700]),
            onPressed: () {
              Get.toNamed(Routes.NOTIFICATIONS);
            },
          ),
          // Firebase Connection Test Button
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[700]),
            onPressed: () {
              FirebaseConnectionService.showConnectionDialog();
            },
            tooltip: 'Firebase Connection Test',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Search
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Enhanced Search Bar with filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.green[700],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          onPressed: () {
                            _showFilterBottomSheet(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Promo Banner
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 160),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[700]!, Colors.green[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Icon(
                            Icons.sports_soccer,
                            size: 80,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SUMMER SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '30% OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'On all national team jerseys',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Shop Now',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Categories with horizontal scroll
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: _categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Obx(
                      () => ChoiceChip(
                        label: Text(category),
                        selected:
                            productController.selectedCategory.value ==
                            category,
                        selectedColor: Colors.green[700],
                        onSelected: (selected) {
                          _filterByCategory(category);
                        },
                        labelStyle: TextStyle(
                          color:
                              productController.selectedCategory.value ==
                                  category
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // Featured Products
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.ALL_PRODUCTS);
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
            // Products Grid
            Padding(
              padding: EdgeInsets.all(20),
              child: Obx(
                () => productController.isLoading.value
                    ? Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green[700]!,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading products...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : _filteredProducts.isEmpty
                    ? Column(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome to Turf-Mate!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your ultimate football products store',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 10),
                          Obx(
                            () => Text(
                              productController.isOnline.value
                                  ? 'Trying to connect to database...'
                                  : 'Working in offline mode',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  productController.initializeSampleData();
                                },
                                icon: Icon(Icons.sports_soccer),
                                label: Text('Load Football Products'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () {
                                  productController.loadProducts();
                                },
                                icon: Icon(Icons.refresh),
                                label: Text('Refresh'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green[700],
                                  side: BorderSide(color: Colors.green[700]!),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Firebase Upload Button in prominent position
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                productController.forceUploadToFirebase();
                              },
                              icon: Icon(Icons.cloud_upload),
                              label: Text('Upload Data to Firebase Database'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  FirebaseConnectionService.showConnectionDialog();
                                },
                                icon: Icon(Icons.cloud_done, size: 16),
                                label: Text('Test Firebase'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[600],
                                ),
                              ),
                              SizedBox(width: 8),
                              Obx(
                                () => !productController.isOnline.value
                                    ? TextButton.icon(
                                        onPressed: () {
                                          productController.syncToFirebase();
                                        },
                                        icon: Icon(
                                          Icons.cloud_upload,
                                          size: 16,
                                        ),
                                        label: Text('Sync to Cloud'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green[600],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: _filteredProducts[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected:
                          productController.selectedCategory.value == category,
                      onSelected: (selected) {
                        _filterByCategory(category);
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('APPLY FILTERS'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
