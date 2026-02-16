# Firestore Index Setup for Support Tickets

## Problem
When you open "My Support Tickets" screen, you see "Error loading tickets". This happens because Firestore requires a composite index for queries that use `where()` + `orderBy()` on different fields.

## Solution

### Step 1: Check Console Output
When you run the app and open "My Support Tickets", check the Flutter console. You should see an error message like:

```
[cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/...
```

### Step 2: Create the Index
1. **Copy the link** from the console error message
2. **Open it in your browser** (it will take you to Firebase Console)
3. **Click "Create Index"** button
4. **Wait 2-5 minutes** for the index to build
5. Firebase will show "Index Status: Building..." → "Index Status: Enabled"

### Step 3: Restart the App
Once the index is created and enabled:
1. Close and restart the app with `flutter run`
2. Navigate to Profile → My Support Tickets
3. It should now work! 🎉

## Alternative: Manual Index Creation

If the link doesn't appear, create the index manually:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **turf-mate**
3. Click **Firestore Database** in left menu
4. Click **Indexes** tab
5. Click **Create Index**

Configure:
- **Collection ID**: `supportTickets`
- **Fields to index**:
  - Field: `userId`, Order: `Ascending`
  - Field: `createdAt`, Order: `Descending`
- **Query scope**: `Collection`

6. Click **Create**
7. Wait for "Enabled" status

## Why This Happens?

Firestore automatically creates single-field indexes, but when you combine:
- `where('userId', isEqualTo: userId)` (filter by user)
- `orderBy('createdAt', descending: true)` (sort by date)

...it needs a **composite index** which must be created manually.

## Note
- This is a one-time setup
- Once created, all users can benefit from it
- The index automatically updates as you add/remove tickets
- No code changes needed after index creation
