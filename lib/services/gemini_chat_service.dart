import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';

class GeminiChatService {
  // IMPORTANT: Replace with your NEW unrestricted API key from https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDAWK34IHlMa0WQR1Q6zONVMHsS2lF89fo';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiChatService() {
    _model = GenerativeModel(
      model: 'models/gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
    _initializeChat();
  }

  void _initializeChat() {
    final systemPrompt = _buildSystemPrompt();
    _chat = _model.startChat(
      history: [
        Content.text(systemPrompt),
        Content.model([
          TextPart(
            'Hello! I am Turf-Mate Assistant. How can I help you with our football products today?',
          ),
        ]),
      ],
    );
  }

  String _buildSystemPrompt() {
    return '''
You are Turf-Mate Assistant, a helpful chatbot for a football products e-commerce app called Turf-Mate.

IMPORTANT RULES:
1. ONLY answer questions about:
   - Products available in our catalog (jerseys, shoes, balls, accessories, training equipment)
   - Product prices, sizes, colors, descriptions
   - Stock availability
   - Order status and delivery information
   - Payment methods (Bkash, Nagad, Rocket, Cash on Delivery)
   - App features and navigation

2. If user asks ANYTHING outside these topics (like general knowledge, weather, news, programming, etc.), politely respond:
   "I'm sorry, I can only help you with Turf-Mate products and orders. Is there anything about our football products I can assist you with?"

3. Be friendly, helpful, and conversational in both English and Bangla (Bengali).

4. When recommending products, use the product context provided in each message.

5. If you don't find specific information in the context, say:
   "Let me check our current inventory..." and suggest the user browse the app or contact support.

6. Keep responses concise (2-3 sentences) unless detailed explanation is needed.

7. Use emojis sparingly (⚽️, 👕, 👟, 🛍️) to make responses friendly.

Ready to assist!
''';
  }

  String _buildProductContext(List<Product> products) {
    if (products.isEmpty) {
      return 'Currently no products available in inventory.';
    }

    final StringBuffer context = StringBuffer();
    context.writeln('\n--- AVAILABLE PRODUCTS ---');

    // Group by category
    final categories = <String, List<Product>>{};
    for (var product in products) {
      categories.putIfAbsent(product.category, () => []).add(product);
    }

    for (var entry in categories.entries) {
      context.writeln('\n${entry.key}:');
      for (var product in entry.value.take(10)) {
        // Limit to 10 per category to save tokens
        context.writeln(
          '- ${product.name} | Price: ৳${product.price.toStringAsFixed(2)} | '
          'Stock: ${product.quantity > 0 ? "In Stock (${product.quantity})" : "Out of Stock"} | '
          'Rating: ${product.rating}/5.0 (${product.reviewCount} reviews) | '
          'Sizes: ${product.sizes.join(", ")}',
        );
      }
    }

    context.writeln('\n--- END PRODUCTS ---\n');
    return context.toString();
  }

  Future<String> sendMessage(String userMessage) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Get product controller
        final productController = Get.find<ProductController>();

        // Build context with current products
        final productContext = _buildProductContext(productController.products);

        // Combine user message with context
        final fullMessage =
            '''
$productContext

User Question: $userMessage

Please answer based ONLY on the product information above and Turf-Mate app features.
''';

        // Send to Gemini
        final response = await _chat.sendMessage(Content.text(fullMessage));

        return response.text ?? 'Sorry, I could not generate a response.';
      } catch (e) {
        retryCount++;
        print('❌ Gemini API Error (Attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          // After all retries failed, return helpful error message
          if (e.toString().contains('Connection')) {
            return '''Sorry, I'm having trouble connecting to my brain right now. 🤯

Please check:
✅ Your internet connection is working
✅ Try again in a few seconds

In the meantime, you can:
• Browse products by category
• Use the search bar to find items
• Check your cart and wishlist

I'll be back online soon! 💚''';
          } else if (e.toString().contains('API key')) {
            return 'API configuration error. Please contact support.';
          } else {
            return '''Oops! Something went wrong on my end. 😅

Please try:
✅ Asking your question differently
✅ Waiting a moment and trying again
✅ Using the search or browse features

Need urgent help? Contact our support team! 📞''';
          }
        }

        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    return 'Sorry, I encountered an error. Please try again.';
  }

  // Reset chat session
  void resetChat() {
    _initializeChat();
  }

  // Get product recommendations
  Future<String> getProductRecommendations(String category) async {
    final message =
        'Can you recommend the best products in $category category?';
    return await sendMessage(message);
  }

  // Search products
  Future<String> searchProducts(String query) async {
    final message = 'Show me products related to: $query';
    return await sendMessage(message);
  }

  // Check stock
  Future<String> checkStock(String productName) async {
    final message = 'Is $productName available in stock?';
    return await sendMessage(message);
  }
}
