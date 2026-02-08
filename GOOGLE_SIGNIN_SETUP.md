# Google Sign-In Setup Instructions

## Firebase Console Configuration

আপনার Google Sign-In সম্পূর্ণভাবে কাজ করার জন্য Firebase Console-এ কিছু সেটআপ করতে হবে:

### 1. Firebase Console-এ যান
1. [Firebase Console](https://console.firebase.google.com/) এ যান
2. আপনার প্রজেক্ট সিলেক্ট করুন (`turf_app`)

### 2. Authentication Enable করুন
1. বাম পাশের মেনু থেকে **Authentication** এ ক্লিক করুন
2. **Get Started** বাটনে ক্লিক করুন (যদি এখনো করা না হয়ে থাকে)
3. **Sign-in method** ট্যাবে যান
4. **Google** সিলেক্ট করুন
5. **Enable** সুইচ টগল করুন
6. **Project support email** সিলেক্ট করুন
7. **Save** বাটনে ক্লিক করুন

### 3. Android এর জন্য SHA-1 Certificate Fingerprint যোগ করুন

#### Debug SHA-1 পাওয়ার জন্য:

**Windows-এ:**
```bash
cd android
./gradlew signingReport
```

অথবা:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Mac/Linux-এ:**
```bash
cd android
./gradlew signingReport
```

অথবা:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

আপনি একটি আউটপুট পাবেন যেখানে SHA-1 fingerprint থাকবে:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

#### Firebase Console-এ SHA-1 যোগ করুন:

1. Firebase Console-এ যান
2. **Project Settings** (গিয়ার আইকন) এ ক্লিক করুন
3. নিচে স্ক্রল করে **Your apps** সেকশনে যান
4. আপনার Android app সিলেক্ট করুন
5. **Add fingerprint** বাটনে ক্লিক করুন
6. SHA-1 certificate fingerprint পেস্ট করুন
7. **Save** করুন

### 4. google-services.json ফাইল আপডেট করুন

SHA-1 যোগ করার পর, আপনাকে নতুন `google-services.json` ফাইল ডাউনলোড করতে হবে:

1. Firebase Console-এ Project Settings-এ যান
2. আপনার Android app-এ **google-services.json** ডাউনলোড করুন
3. পুরানো ফাইলটি রিপ্লেস করুন: `android/app/google-services.json`

### 5. Release Build এর জন্য (Production)

Release build এর জন্য একটি signing key তৈরি করতে হবে:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

তারপর SHA-1 বের করুন:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

এই SHA-1ও Firebase Console-এ যোগ করুন।

## Testing

### আপনার অ্যাপ টেস্ট করতে:

1. Dependencies ইন্সটল করুন:
```bash
flutter pub get
```

2. Android emulator অথবা physical device চালু করুন

3. অ্যাপ রান করুন:
```bash
flutter run
```

4. Login screen-এ যান এবং Google icon-এ ক্লিক করুন

5. একটি Google account সিলেক্ট করুন

6. সফলভাবে লগইন হয়ে যাবে!

## Troubleshooting

### Error: "Developer Error" or "Sign in failed"
- নিশ্চিত করুন যে SHA-1 fingerprint সঠিকভাবে Firebase Console-এ যোগ করা হয়েছে
- নতুন `google-services.json` ফাইল ডাউনলোড করে `android/app/` তে রিপ্লেস করেছেন
- অ্যাপ আনইন্সটল করে আবার ইন্সটল করুন
- Clean build করুন: `flutter clean && flutter pub get`

### Error: "apiKey not found"
- `google-services.json` ফাইল সঠিক জায়গায় আছে কিনা চেক করুন (`android/app/`)
- Firebase Console-এ Google Sign-In enable করা আছে কিনা চেক করুন

### Build fails
- `flutter clean` রান করুন
- `flutter pub get` রান করুন
- Android Studio cache clear করুন: **File > Invalidate Caches / Restart**

## Features Implemented

✅ Google Sign-In with Firebase Authentication
✅ Email/Password Authentication
✅ User data stored in Firestore
✅ Auto-login on app restart
✅ Logout functionality
✅ Password reset

## Files Modified/Created

### Created:
- `lib/services/auth_service.dart` - Firebase Authentication service
- `GOOGLE_SIGNIN_SETUP.md` - This setup guide

### Modified:
- `pubspec.yaml` - Added firebase_auth and google_sign_in packages
- `lib/controllers/auth_controller.dart` - Integrated Firebase Auth
- `lib/widgets/social_login_button.dart` - Added onTap callback
- `lib/screens/auth/login_screen.dart` - Added Google Sign-In button
- `lib/screens/auth/register_screen.dart` - Added Google Sign-In button
- `lib/main.dart` - Added AuthService initialization

## Next Steps

আপনি চাইলে আরও authentication methods যোগ করতে পারেন:
- Facebook Login
- Phone Authentication
- Apple Sign-In
- Anonymous Authentication
