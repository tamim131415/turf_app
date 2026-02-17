# API Keys Setup Guide

## 🔐 Secure API Key Management

This project uses a secure method to manage API keys, preventing them from being accidentally committed to version control.

## 📋 Setup Instructions

### First Time Setup

1. **Locate the template file:**
   - File: `lib/config/api_keys_template.dart`

2. **Create your config file:**
   - A file `lib/config/api_keys.dart` has been created for you
   - This file is in `.gitignore` and will NEVER be committed to git

3. **Add your API keys:**
   - Open `lib/config/api_keys.dart`
   - Replace `'PLEASE_PROVIDE_YOUR_API_KEY'` with your actual Gemini API key
   - Get your key from: https://aistudio.google.com/app/apikey

4. **Example:**
   ```dart
   class ApiKeys {
     static const String geminiApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXX';
   }
   ```

## ✅ Security Features

- ✓ `lib/config/api_keys.dart` is in `.gitignore` - never committed
- ✓ Template file shows structure without exposing actual keys
- ✓ Both Gemini services (`gemini_chat_service.dart` and `gemini_chat_service_http.dart`) use this config
- ✓ Safe to share your code repository

## 🚨 Important Notes

- **NEVER** commit `lib/config/api_keys.dart` to git
- **ALWAYS** use the template file for documentation
- **CHECK** that api_keys.dart is in .gitignore before pushing

## 🔄 For Team Members

If you clone this repository:

1. Copy `lib/config/api_keys_template.dart`
2. Rename it to `lib/config/api_keys.dart`
3. Add your own API keys
4. Start developing!

## 📝 Adding New API Keys

To add more API keys (Cloudinary, Firebase, etc.):

1. Add them to both `api_keys_template.dart` and `api_keys.dart`:
   ```dart
   class ApiKeys {
     static const String geminiApiKey = 'YOUR_KEY';
     static const String cloudinaryKey = 'YOUR_KEY';
     static const String firebaseKey = 'YOUR_KEY';
   }
   ```

2. Import and use in your services:
   ```dart
   import '../config/api_keys.dart';
   
   static const String myKey = ApiKeys.cloudinaryKey;
   ```

---

**✨ Your API keys are now secure and won't be leaked!**
