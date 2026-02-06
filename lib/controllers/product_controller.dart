import 'package:get/get.dart';
import '../models/product.dart';
import '../services/demo_service.dart';

class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> favoriteProducts = <Product>[].obs;
  final RxList<Product> cartItems = <Product>[].obs;
  final RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    products.value = DemoService.getProducts();
    updateFavoriteProducts();
  }

  void toggleFavorite(Product product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // In a real app, you would update the product in the service/API
      // For now, we'll just update the local list
      updateFavoriteProducts();
    }
  }

  void updateFavoriteProducts() {
    favoriteProducts.value = products.where((p) => p.isFavorite).toList();
  }

  void addToCart(Product product) {
    cartItems.add(product);
    Get.snackbar('Success', '${product.name} added to cart');
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  List<Product> get filteredProducts {
    if (selectedCategory.value == 'All') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  double get cartTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.price);
  }
}
