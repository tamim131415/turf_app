# Turf-Mate AI Chatbot Setup Guide

## Overview
The chatbot is powered by Google Gemini AI and helps users with:
- Product search and recommendations
- Stock availability checks
- Price information
- Order tracking
- General app navigation

## Setup Instructions

### Step 1: Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Get API Key"** or **"Create API Key"**
4. Copy the generated API key

### Step 2: Add API Key to the App

1. Open the file: `lib/services/gemini_chat_service.dart`
2. Find line 9:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
   ```dart
   static const String _apiKey = 'AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567';
   ```

### Step 3: Test the Chatbot

1. Run the app: `flutter run`
2. On the home screen, tap the **"Chat Assistant"** floating button (green button at bottom right)
3. Try asking:
   - "Show me Argentina jerseys"
   - "What products are under 1000 taka?"
   - "Is Size M available?"
   - "Show me best selling products"

## Features

### 1. **Smart Context**
- Chatbot has access to your entire product catalog
- Knows about stock levels, prices, sizes, and categories
- Responds based ONLY on your app data

### 2. **Bilingual Support**
- Works in both English and Bangla (Bengali)
- User can ask questions in either language

### 3. **Quick Actions**
- Pre-defined buttons for common queries:
  - Jerseys
  - Shoes
  - Balls
  - Under ৳1000

### 4. **Chat History**
- All conversations saved to Firestore
- Each user has their own chat history
- Can clear chat anytime

### 5. **Smart Responses**
- If user asks off-topic questions, bot politely redirects to product queries
- Provides helpful, concise answers
- Uses emojis for friendly experience

## Customization

### Modify System Prompt (Advanced)

Edit `lib/services/gemini_chat_service.dart` - `_buildSystemPrompt()` method to customize:
- Bot personality
- Response style
- Which topics to handle
- Language preferences

### Adjust Product Context

Edit `_buildProductContext()` method to:
- Limit products per category
- Change the information format
- Add more product details

### Change Model Parameters

In `GeminiChatService()` constructor:
```dart
GenerationConfig(
  temperature: 0.7,  // 0-1: Lower = more focused, Higher = more creative
  topK: 40,          // Number of tokens to consider
  topP: 0.95,        // Cumulative probability threshold
  maxOutputTokens: 1024, // Maximum response length
)
```

## API Usage & Costs

### Free Tier
- 15 requests per minute
- 1,500 requests per day
- FREE forever

### Pricing (if exceeded)
- Input: $0.00025 per 1K characters (~৳0.03)
- Output: $0.0005 per 1K characters (~৳0.06)

### Estimated Monthly Cost
For 1000 active users, 5 messages each:
- 5000 conversations
- Average: 2000 tokens input + 200 tokens output per conversation
- **Total: ~৳500-800/month**

## Firestore Security Rules

Add these rules to protect chat data:

```javascript
match /users/{userId}/chatHistory/{messageId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Troubleshooting

### "API Key not valid"
- Double-check you copied the full API key
- Make sure there are no extra spaces
- Regenerate key if needed

### "Connection error"
- Check internet connection
- Verify Firebase is initialized
- Check Firestore permissions

### Bot gives wrong information
- The bot uses product data from `ProductController`
- Make sure products are loading correctly
- Check `_buildProductContext()` is formatting data properly

### Responses are slow
- Free tier has 15 requests/minute limit
- Consider caching frequent queries
- Reduce context size if too large

## Support

For issues or questions:
1. Check console logs for errors
2. Verify API key is correct
3. Test with simple queries first
4. Check Firebase console for saved messages

## Next Steps

### Recommended Enhancements:
1. **Product Images in Chat** - Show product images with recommendations
2. **Quick Add to Cart** - Allow adding products directly from chat
3. **Order Tracking** - Integrate with order system for status updates
4. **Rich Messages** - Add buttons, carousels for better UX
5. **Voice Input** - Add speech-to-text for voice queries
6. **Analytics** - Track popular queries to improve inventory

---

**Chatbot is now ready to use!** 🎉

Users can access it via the floating "Chat Assistant" button on the home screen.
