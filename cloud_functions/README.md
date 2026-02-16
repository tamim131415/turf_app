# Quick Setup (Bangla)

## সহজ ভাষায় Cloud Function Setup:

### 1️⃣ Firebase Console এ যাও
```
https://console.firebase.google.com
→ তোমার project select করো
→ Functions click করো
→ Get Started button click করো
→ Blaze Plan upgrade করো (FREE থাকবে,걱정 নাই!)
```

### 2️⃣ Computer এ Firebase CLI Install করো
```bash
# Command Prompt/PowerShell open করো

# Node.js আছে কিনা check করো
node --version

# না থাকলে install করো: https://nodejs.org/

# Firebase CLI install করো
npm install -g firebase-tools

# Firebase login করো
firebase login
```

### 3️⃣ Project Initialize করো
```bash
# তোমার turf_app folder এ যাও
cd d:\Apps\turf_app

# Firebase initialize করো
firebase init functions

# Questions এ answer:
# - Select project: তোমার Firebase project
# - Language: JavaScript
# - ESLint: No
# - Install dependencies: Yes
```

### 4️⃣ Code Copy করো
```bash
# এই file এর code copy করো
d:\Apps\turf_app\cloud_functions\index.js

# Paste করো এখানে
d:\Apps\turf_app\functions\index.js

# Or command দিয়ে:
copy cloud_functions\index.js functions\index.js
copy cloud_functions\package.json functions\package.json
```

### 5️⃣ Deploy করো
```bash
cd d:\Apps\turf_app

firebase deploy --only functions

# Success message দেখবে! ✅
```

### 6️⃣ Test করো
```
1. App install করো
2. Customer login করো  
3. Order place করো
4. Admin থেকে order status change করো
5. Customer notification পাবে! 🔔
```

---

## প্রয়োজনীয় জিনিস:

- ✅ Node.js (https://nodejs.org/)
- ✅ Firebase account
- ✅ Credit card (Blaze plan এর জন্য - charge হবে না!)
- ✅ Internet connection

---

## Cost কত?

একদম **FREE!** 

তোমার app এ যত notification যাবে সব **FREE tier** এ থাকবে।

Monthly 100,000 notifications পাঠালেও **$0.00** cost!

---

## Help দরকার?

Full guide দেখো: `CLOUD_FUNCTION_SETUP.md`

Or video tutorial: https://firebase.google.com/docs/functions/get-started

---

## Files:

```
cloud_functions/
├── index.js          ← Cloud Function code  
├── package.json      ← Dependencies
└── README.md         ← This file
```

Copy করবে এখানে:

```
functions/
├── index.js          ← Paste here
├── package.json      ← Paste here
```

তারপর deploy:

```bash
firebase deploy --only functions
```

**Done!** ✅
