import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/gemini_chat_service_http.dart'; // Changed to HTTP version
import '../services/auth_service.dart';

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSendingMessage = false.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final GeminiChatService _geminiService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  String? get userId => _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _geminiService = GeminiChatService();
    _loadChatHistory();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _addWelcomeMessage() {
    if (messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Hello! 👋 I\'m your Turf-Mate Assistant. I can help you with:\n\n⚽️ Finding products\n💰 Checking prices & stock\n📦 Order status\n🛍️ Product recommendations\n\nWhat would you like to know?',
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      );
      messages.add(welcomeMessage);
      _saveChatMessage(welcomeMessage);
    }
  }

  Future<void> _loadChatHistory() async {
    if (userId == null) return;

    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatHistory')
          .orderBy('timestamp', descending: false)
          .limit(50) // Load last 50 messages
          .get();

      final history = snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();

      if (history.isNotEmpty) {
        messages.value = history;
      }
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSendingMessage.value) return;

    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      userId: userId,
    );

    // Add to UI and clear input
    messages.add(userMessage);
    messageController.clear();
    _scrollToBottom();

    // Save user message
    await _saveChatMessage(userMessage);

    // Get AI response
    isSendingMessage.value = true;

    try {
      final responseText = await _geminiService.sendMessage(text);

      // Create bot message
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      );

      messages.add(botMessage);
      await _saveChatMessage(botMessage);
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Sorry, I encountered an error. Please try again or contact support.',
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      );
      messages.add(errorMessage);
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> _saveChatMessage(ChatMessage message) async {
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatHistory')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      debugPrint('❌ Error saving message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Chat History'),
        content: Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _clearChatFromFirestore();
              messages.clear();
              _geminiService.resetChat();
              _addWelcomeMessage();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChatFromFirestore() async {
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatHistory')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('❌ Error clearing chat: $e');
    }
  }

  // Quick action methods
  void askAboutCategory(String category) {
    messageController.text = 'Show me $category products';
    sendMessage();
  }

  void askAboutPrice(double maxPrice) {
    messageController.text = 'What products are available under ৳$maxPrice?';
    sendMessage();
  }

  void askAboutStock(String productName) {
    messageController.text = 'Is $productName in stock?';
    sendMessage();
  }
}
