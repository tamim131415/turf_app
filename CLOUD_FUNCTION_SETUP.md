# 🚀 Cloud Function Setup Guide (Step by Step)

## Option 1: Firebase Console Diye Setup (সবচেয়ে সহজ)

### Step 1: Firebase Console Open Koro
1. Browser e jao: https://console.firebase.google.com
2. Tumhar Flutter app er project select koro (turf_app)
3. Left sidebar e **"Functions"** e click koro

### Step 2: Functions Enable Koro
1. "Get Started" button e click koro
2. **Blaze Plan** (Pay as you go) upgrade korte bolbe
   - ⚠️ Don't worry! Free tier e tumhar usage free thakbe
   - Credit card add korte hobe but charge hobena (free limit e)
3. "Continue" te click koro

### Step 3: Firebase CLI Install Koro (One Time)
Windows PowerShell/CMD open koro:

```bash
# Node.js install ache ki check koro
node --version

# Na thakle download koro: https://nodejs.org/

# Firebase CLI install koro
npm install -g firebase-tools

# Firebase login koro
firebase login
```

### Step 4: Firebase Project Initialize Koro
Tumhar project folder e jao (turf_app):

```bash
cd d:\Apps\turf_app

# Firebase initialize koro
firebase init functions

# Prompts e answer koro:
# ? Select a default Firebase project: Select tumhar project
# ? What language: JavaScript
# ? Do you want to use ESLint: No
# ? Do you want to install dependencies: Yes
```

### Step 5: Cloud Function Code Copy Koro
File already create korechi: `d:\Apps\turf_app\cloud_functions\index.js`

Eita copy koro:
```bash
# functions folder e index.js te code copy paste koro
copy d:\Apps\turf_app\cloud_functions\index.js d:\Apps\turf_app\functions\index.js
```

Or manually copy koro:
1. `d:\Apps\turf_app\cloud_functions\index.js` file open koro
2. All code copy koro
3. `d:\Apps\turf_app\functions\index.js` file e paste koro

### Step 6: Deploy Cloud Function
```bash
cd d:\Apps\turf_app

# Deploy koro
firebase deploy --only functions

# Wait korbo... success message ashbe
# ✅ Function deployed: sendFCMNotifications
```

### Step 7: Test Koro
1. App install koro device e
2. Customer login koro
3. Order place koro
4. Admin login koro
5. Order status change koro (Confirmed)
6. **Customer notification pabe!** 🔔

---

## Option 2: Without Credit Card (Alternative)

Jodi Blaze plan e upgrade korte na chao, tumi **direct Firestore theke notification send** korte paro admin app theke.

### Admin App e Code Add Koro:

Admin app e order status update korar time e:

```dart
// When admin changes order status, send notification directly
Future<void> sendNotificationDirectly(String fcmToken, String title, String message) async {
  // Need to use HTTP package to call FCM REST API
  // But this requires FCM Server Key
  // Which should NOT be in client app (security issue)
}
```

⚠️ **Problem:** Client app theke direct FCM send kora secure na. Cloud Function best practice.

---

## 💰 Cost Breakdown (Blaze Plan)

| Resource | Free Tier | Your Usage | Will You Pay? |
|----------|-----------|------------|---------------|
| Cloud Functions | 2 Million calls/month | ~3,000/month (100 orders/day) | **NO** ✅ |
| Firestore Reads | 50,000/day | ~100/day | **NO** ✅ |
| Firestore Writes | 20,000/day | ~100/day | **NO** ✅ |
| FCM Messages | Unlimited | Unlimited | **NO** ✅ |

**Result: 100% FREE for your usage!** 🎉

Even if you get 1000 orders/day, still FREE!

---

## ✅ Checklist

### Prerequisites:
- [ ] Node.js installed (check: `node --version`)
- [ ] Firebase account
- [ ] Credit card (for Blaze plan verification - won't be charged)

### Setup Steps:
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Firebase login done (`firebase login`)
- [ ] Functions initialized (`firebase init functions`)
- [ ] Code copied to `functions/index.js`
- [ ] Functions deployed (`firebase deploy --only functions`)

### Testing:
- [ ] App installed on device
- [ ] User logged in (FCM token saved)
- [ ] Order placed
- [ ] Admin changed order status
- [ ] Customer received notification ✅

---

## 🐛 Troubleshooting

### Error: "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### Error: "You must be authenticated"
```bash
firebase logout
firebase login
```

### Error: "Billing account required"
- You need to upgrade to Blaze plan
- Add credit card (won't be charged for free tier usage)
- Or use Alternative method

### Function deployed but notifications not working:
1. Check Firestore: `fcmNotificationQueue` collection e document create hoiche ki?
2. Firebase Console → Functions → Logs check koro
3. Check FCM token valid ache ki (users collection e)
4. App e notification permission granted ache ki

### Notification permission denied:
- Settings → Apps → Turf Mate → Notifications → Enable koro

---

## 📖 Next Steps After Setup

### Monitor Notifications:
1. Firebase Console → Functions → Logs
2. View execution history
3. Check success/failure rates

### Add More Notification Types:
- New product added
- Price drop alert
- Flash sale
- Low stock alert (for admin)

### Customize Notifications:
- Add images to notifications
- Add action buttons (View Order, Track, etc)
- Add custom sounds
- Add notification channels

---

## 💡 Important Notes

### Security:
- ✅ Cloud Functions run on server (secure)
- ✅ FCM tokens safely stored in Firestore
- ✅ No API keys in client app

### Performance:
- Functions auto-scale (handles traffic spikes)
- Cold start: ~1-2 seconds first time
- Warm start: <100ms

### Maintenance:
- No maintenance required
- Auto updates by Firebase
- Monitoring through Firebase Console

---

## 🎯 Summary

### What You Need to Do:
1. **Enable Blaze Plan** (Free for your usage)
2. **Install Firebase CLI** (One time)
3. **Deploy Function** (5 minutes)
4. **Test** (Place order → Change status → Get notification)

### What Happens Automatically:
1. Order status changes
2. Notification queued in Firestore
3. Cloud Function triggers automatically
4. FCM sends notification to customer
5. Status updated to 'sent'

**That's it! Fully automated notification system, 100% FREE!** 🎉
