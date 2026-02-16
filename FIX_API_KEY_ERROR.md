# Fix: "API key not valid" Error

## Problem
Getting error: `API key not valid. Please pass a valid API key`

## Root Causes
1. API key has restrictions (IP, Android app, HTTP referrer)
2. Generative Language API not enabled
3. API key was copied incorrectly
4. Using wrong API key type

---

## Solution: Create NEW Unrestricted API Key

### Step 1: Go to Google AI Studio
https://aistudio.google.com/app/apikey

### Step 2: Create New API Key
1. Click **"Create API Key"** button
2. Select **"Create API key in new project"** 
3. Wait for key generation (takes 5-10 seconds)
4. **Copy the entire key** (starts with `AIzaSy...`)

### Step 3: Verify Key Has NO Restrictions
1. Click on the key name to open details
2. Scroll to **"API restrictions"**
3. Make sure it says **"None"** or **"Unrestricted"**
4. If not, click **"Edit"** → Select **"Don't restrict key"** → **"Save"**

### Step 4: Update in Your App
1. Open: `lib/services/gemini_chat_service.dart`
2. Line 8: Replace the API key:
   ```dart
   static const String _apiKey = 'YOUR_NEW_API_KEY_HERE';
   ```
3. Paste your new key (keep the quotes)

### Step 5: Rebuild and Test
```bash
flutter clean
flutter pub get
flutter run
```

---

## Alternative: Configure Existing Key for Android

### Option 1: Remove All Restrictions (Recommended for Testing)
1. Go to: https://aistudio.google.com/app/apikey
2. Click your key name
3. Find **"API restrictions"**
4. Select **"None"**
5. Click **"Save"**
6. Wait 1-2 minutes for changes to propagate

### Option 2: Add Android App Restriction
1. In API restrictions, select **"Android apps"**
2. Click **"Add an app"**
3. Add package name: Check `android/app/build.gradle` for `applicationId`
   - Should be like: `com.example.turf_app`
4. Add SHA-1 fingerprint:
   
   **For Debug Build:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   
   **For Windows:**
   ```bash
   keytool -list -v -keystore "C:\Users\YOUR_USERNAME\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   
5. Copy the **SHA-1** line (looks like: `AA:BB:CC:DD:...`)
6. Paste in Google AI Studio
7. Click **"Save"**

---

## Verify API Key is Working

### Test 1: Using Browser
1. Go to: https://aistudio.google.com/app/prompts/new_chat
2. Type a test message
3. If it works → Key is valid, issue is with restrictions

### Test 2: Using cURL (Command Line)
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

If you get a response → Key works!
If you get error → Key is invalid

---

## Common Issues

### "API not enabled"
**Fix:** Enable the API
1. Go to: https://console.cloud.google.com/apis/library
2. Search: **"Generative Language API"**
3. Click it → Click **"Enable"**
4. Wait 1-2 minutes

### "Quota exceeded"
**Fix:** Wait 24 hours (free tier: 1500 requests/day)

### "Daily limit exceeded"
**Fix:** You've exceeded free tier
- Upgrade to paid plan, OR
- Wait until next day

### Key works in browser but not in app
**Fix:** Restrictions issue
- Remove all restrictions (Option 1 above)
- Or properly configure Android restriction (Option 2 above)

---

## Quick Fix Checklist

☐ Created NEW API key in Google AI Studio
☐ Verified it has NO restrictions
☐ Copied entire key (including `AIzaSy...` prefix)
☐ Pasted in `gemini_chat_service.dart` line 8
☐ Ran `flutter clean` and `flutter pub get`
☐ Tested in app

---

## Still Not Working?

### 1. Check Package Name Matches
**In code:** `android/app/build.gradle` → `applicationId`
**In AndroidManifest:** `<manifest package="...">`
Both should match!

### 2. Use Different Google Account
Sometimes corporate accounts have restrictions. Try:
- Personal Gmail account
- Incognito window to create key

### 3. Check Console for Exact Error
```bash
flutter run --verbose
```
Look for exact error message in logs

### 4. Temporary Workaround: Use Different Model
Try `gemini-1.5-flash` instead:
```dart
_model = GenerativeModel(
  model: 'gemini-1.5-flash',  // Changed from gemini-pro
  apiKey: _apiKey,
  ...
)
```

---

## Contact Support

If nothing works:
1. Copy the full error from console
2. Screenshot your API key restrictions page (hide the actual key!)
3. Check: https://ai.google.dev/docs/gemini_api_overview

**API Key should now work!** 🎉
