# ⚠️ Email/Password Authentication Setup

## আপনার Error টি Solve করতে এই Steps Follow করুন:

### Error Message:
```
This operation is not allowed. This may be because the given sign-in provider 
is disabled for this Firebase project.
```

এর মানে হলো Firebase Console-এ **Email/Password authentication** enable করা নেই।

---

## Solution (5 মিনিটে শেষ):

### Step 1: Firebase Console এ যান
1. Browser এ যান: https://console.firebase.google.com/
2. আপনার প্রজেক্ট **turf-mate-7d89c** সিলেক্ট করুন

### Step 2: Authentication Page এ যান
1. বাম পাশের মেনু থেকে **🔐 Authentication** এ ক্লিক করুন
2. যদি প্রথমবার হয়, তাহলে **Get Started** বাটনে ক্লিক করুন

### Step 3: Sign-in Method Configure করুন
1. উপরের **Sign-in method** ট্যাবে ক্লিক করুন
2. Provider list এ **Email/Password** খুঁজুন
3. **Email/Password** এর উপর ক্লিক করুন
4. একটি dialog box খুলবে

### Step 4: Email/Password Enable করুন
1. প্রথম option **"Enable"** switch টি **ON** করুন
2. নিচের **"Email link (passwordless sign-in)"** option টি OFF রাখুন
3. **Save** বাটনে ক্লিক করুন

### Step 5: Verify করুন
Sign-in method list এ **Email/Password** এর পাশে **"Enabled"** লেখা আসবে। ✅

---

## এখন আপনার App Test করুন:

1. **Hot Restart** করুন:
   ```bash
   R (in terminal)
   ```

2. **Create Account** screen থেকে registration করুন
   - Name, Email, Password দিন
   - **CREATE ACCOUNT** চাপুন

3. ✅ এখন কাজ করবে এবং আপনার email এ verification link যাবে!

---

## Checklist:

- [ ] Firebase Console এ গিয়েছি
- [ ] Authentication > Sign-in method page এ গিয়েছি  
- [ ] Email/Password provider Enable করেছি
- [ ] Save করেছি
- [ ] App restart করেছি
- [ ] Registration test করেছি

---

## যদি এখনও Problem হয়:

### Google Sign-In ও enable করুন:
1. একই Sign-in method page এ
2. **Google** provider ক্লিক করুন
3. **Enable** করুন
4. **Project support email** select করুন
5. **Save** করুন

### Check করুন:
- Internet connection আছে কিনা
- Firebase project সঠিক কিনা (turf-mate-7d89c)
- google-services.json ফাইল সঠিক জায়গায় আছে কিনা

---

## Screenshots Reference:

### কোথায় Email/Password পাবেন:
```
Firebase Console
  └── Authentication
       └── Sign-in method (tab)
            └── Email/Password (click করুন)
                 └── Enable (switch ON করুন)
                      └── Save
```

---

## Need More Help?

এই steps follow করার পরও যদি কাজ না করে:
1. Terminal এর error message পুরোটা copy করুন
2. Firebase Console এ Email/Password "Enabled" দেখাচ্ছে কিনা screenshot নিন
3. Help চান

---

**সময় লাগবে:** ⏱️ মাত্র 2-3 মিনিট
**Difficulty:** ⭐ Very Easy
