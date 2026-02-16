# Chatbot Network Troubleshooting Guide

## Issue Fixed: "Connection reset by peer"

### Changes Made:

1. **Android Network Configuration**
   - Added `network_security_config.xml` to allow HTTPS connections
   - Added `ACCESS_NETWORK_STATE` and `ACCESS_WIFI_STATE` permissions
   - Enabled cleartext traffic for debugging

2. **Improved Error Handling**
   - Added retry logic (3 attempts with exponential backoff)
   - Better error messages for users
   - Detailed logging for debugging

3. **API Configuration**
   - Network security config added for Gemini API domain
   - Trust system and user certificates

---

## How to Test After Fix:

### 1. Clean Build
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### 2. Test on Real Device (Recommended)
The emulator sometimes has network issues. Test on a real Android device:
```bash
flutter run -d <device-id>
```

### 3. Check Internet Connection
Make sure your device/emulator has active internet:
- Open browser and visit google.com
- Check WiFi/mobile data is enabled

---

## If Still Not Working:

### Option 1: Restart ADB
```bash
adb kill-server
adb start-server
flutter run
```

### Option 2: Check Emulator Network
```bash
# In emulator settings:
Settings → Network & Internet → Internet → Check connection
```

### Option 3: Test API Key Directly

Create a test file `test_gemini.dart`:
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'YOUR_API_KEY',
  );
  
  try {
    final response = await model.generateContent([Content.text('Hello')]);
    print('✅ Success: ${response.text}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

Run: `dart test_gemini.dart`

### Option 4: Use VPN (If in Restricted Region)
Some countries may have restrictions on Google APIs. Try using a VPN.

### Option 5: Check Firewall
Ensure your firewall/antivirus isn't blocking the connection.

---

## Error Messages Explained:

### "Connection reset by peer"
- **Cause**: Network interruption or SSL/TLS handshake failure
- **Fix**: Network security config added ✅

### "API key not valid"
- **Cause**: Wrong or expired API key
- **Fix**: Verify key in `gemini_chat_service.dart`

### "Quota exceeded"
- **Cause**: Free tier limit reached (1500/day)
- **Fix**: Wait 24 hours or upgrade plan

---

## Alternative: Use Fallback Mode

If Gemini API is consistently failing, you can implement a fallback search:

Edit `chat_controller.dart` → `sendMessage()`:
```dart
// If Gemini fails, use local search
if (responseText.contains('trouble connecting')) {
  // Search local products instead
  final searchResults = productController.products
      .where((p) => p.name.toLowerCase().contains(text.toLowerCase()))
      .take(3);
  
  if (searchResults.isNotEmpty) {
    final products = searchResults.map((p) => 
      '${p.name} - ৳${p.price}'
    ).join('\n');
    
    responseText = 'Here are some matches:\n\n$products';
  }
}
```

---

## Support

If issues persist:
1. Check console logs: `flutter run --verbose`
2. Enable debug mode in `gemini_chat_service.dart`
3. Test API directly using Postman/curl
4. Contact Google Cloud Support if API key issue

API should now work correctly! 🎉
