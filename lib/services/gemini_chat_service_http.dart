import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import '../config/api_keys.dart';

class GeminiChatService {
  // API key is now securely stored in lib/config/api_keys.dart (not committed to git)
  static const String _apiKey = ApiKeys.geminiApiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  List<Map<String, dynamic>> _chatHistory = [];

  String _buildSystemPrompt() {
    return '''
You are Turf-Mate Assistant, a helpful chatbot for a football products e-commerce app.

IMPORTANT RULES:
1. ONLY answer about products, orders, delivery, and payment
2. If asked anything else, politely redirect to shop topics
3. Be friendly in both English and Bangla
4. Keep responses short (2-3 sentences)

Ready to assist!
''';
  }

  String _buildProductContext(List<Product> products) {
    if (products.isEmpty) {
      return 'No products available.';
    }

    final StringBuffer context = StringBuffer();
    context.writeln('\n--- PRODUCTS ---');

    final categories = <String, List<Product>>{};
    for (var product in products) {
      categories.putIfAbsent(product.category, () => []).add(product);
    }

    for (var entry in categories.entries) {
      context.writeln('\n${entry.key}:');
      for (var product in entry.value.take(10)) {
        context.writeln(
          '- ${product.name} | ৳${product.price.toStringAsFixed(2)} | '
          'Stock: ${product.quantity > 0 ? "✓" : "✗"} | '
          'Rating: ${product.rating}/5',
        );
      }
    }

    context.writeln('\n---');
    return context.toString();
  }

  Future<String> sendMessage(String userMessage) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final productController = Get.find<ProductController>();
        final productContext = _buildProductContext(productController.products);

        // Build conversation contents with history
        List<Map<String, dynamic>> contents = [];

        // First message includes system prompt and product context
        if (_chatHistory.isEmpty) {
          contents.add({
            "role": "user",
            "parts": [
              {"text": _buildSystemPrompt() + productContext},
            ],
          });
          contents.add({
            "role": "model",
            "parts": [
              {
                "text":
                    "Hello! 👋 I'm ready to help you with products, orders, and delivery.",
              },
            ],
          });
        }

        // Add chat history
        for (var message in _chatHistory) {
          contents.add(message);
        }

        // Add current user message
        contents.add({
          "role": "user",
          "parts": [
            {"text": userMessage},
          ],
        });

        final requestBody = {
          "contents": contents,
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          },
        };

        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final text =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          final botResponse = text ?? 'Sorry, could not generate response.';

          // Store in history
          _chatHistory.add({
            "role": "user",
            "parts": [
              {"text": userMessage},
            ],
          });
          _chatHistory.add({
            "role": "model",
            "parts": [
              {"text": botResponse},
            ],
          });

          // Keep only last 10 message pairs (20 messages total)
          if (_chatHistory.length > 20) {
            _chatHistory.removeRange(0, _chatHistory.length - 20);
          }

          return botResponse;
        } else {
          throw Exception(
            'API Error: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        retryCount++;
        print('❌ Gemini API Error (Attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          if (e.toString().contains('Connection')) {
            return '''Sorry, I'm having trouble connecting right now. 🤯

Please check:
✅ Your internet connection
✅ Try again in a few seconds

You can browse products or use search! 💚''';
          } else {
            return '''Oops! Something went wrong. 😅

Try:
✅ Asking differently
✅ Using search or browse
✅ Contact support if urgent 📞''';
          }
        }

        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    return 'Sorry, please try again.';
  }

  void resetChat() {
    _chatHistory.clear();
  }
}
