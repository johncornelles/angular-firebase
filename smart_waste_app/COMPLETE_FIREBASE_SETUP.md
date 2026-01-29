# Complete Firebase Setup Guide for Smart Waste Collection App

Follow these steps **exactly** to get your app fully working with Firebase.

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `smart-waste-collection`
4. Click Continue → Enable/Disable Google Analytics (optional) → Create Project
5. Wait for project creation to complete

---

## Step 2: Enable Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. Toggle **"Enable"** to ON
6. Click **Save**

---

## Step 3: Create Firestore Database

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (we'll add rules later)
4. Choose a location closest to your users
5. Click **Enable**

### Add Security Rules
After database is created:
1. Go to **Rules** tab
2. Replace the content with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
      allow read, update: if isAdmin();
    }
    
    match /zones/{zoneId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    match /schedules/{scheduleId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    match /notifications/{notificationId} {
      allow read: if isAuthenticated();
      allow update: if isAuthenticated();
      allow create, delete: if isAdmin();
    }
  }
}
```

3. Click **Publish**

---

## Step 4: Add Sample Data to Firestore

In Firestore Console, create the following collections and documents:

### Collection: `zones`

Click **"Start collection"** → Collection ID: `zones`

**Document 1:**
- Document ID: `zone_downtown`
- Fields:
  - `zoneName` (string): `Downtown District`
  - `description` (string): `Central business district area`
  - `latitude` (number): `12.9716`
  - `longitude` (number): `77.5946`
  - `createdAt` (timestamp): (click clock icon, select current date)

**Document 2:** (Click "Add document")
- Document ID: `zone_north`
- Fields:
  - `zoneName` (string): `Residential North`
  - `description` (string): `Northern residential neighborhoods`
  - `latitude` (number): `12.9816`
  - `longitude` (number): `77.6046`
  - `createdAt` (timestamp): current date

**Document 3:**
- Document ID: `zone_south`
- Fields:
  - `zoneName` (string): `South Bay Area`
  - `description` (string): `Southern coastal region`
  - `latitude` (number): `12.9616`
  - `longitude` (number): `77.5846`
  - `createdAt` (timestamp): current date

**Document 4:**
- Document ID: `zone_industrial`
- Fields:
  - `zoneName` (string): `Industrial Zone`
  - `description` (string): `Eastern industrial district`
  - `latitude` (number): `12.9716`
  - `longitude` (number): `77.6146`
  - `createdAt` (timestamp): current date

---

## Step 5: Register Web App & Get Config

1. In Firebase Console, click the **gear icon** → **Project settings**
2. Scroll down to **"Your apps"** section
3. Click the **Web icon** (`</>`)
4. Register app:
   - App nickname: `WasteAlert Web`
   - ❌ Don't check "Firebase Hosting"
   - Click **Register app**
5. You'll see a config object like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "smart-waste-collection.firebaseapp.com",
  projectId: "smart-waste-collection",
  storageBucket: "smart-waste-collection.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123def456"
};
```

6. **Copy these values** - you'll need them in the next step!

---

## Step 6: Update Your App Configuration

Open `lib/firebase_options.dart` and replace the placeholder values:

```dart
// Web configuration - REPLACE WITH YOUR VALUES
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',           // ← Replace
  appId: 'YOUR_APP_ID_HERE',             // ← Replace
  messagingSenderId: 'YOUR_SENDER_ID',   // ← Replace
  projectId: 'YOUR_PROJECT_ID',          // ← Replace
  authDomain: 'YOUR_PROJECT.firebaseapp.com',  // ← Replace
  storageBucket: 'YOUR_PROJECT.appspot.com',   // ← Replace
);
```

---

## Step 7: Enable Cloud Messaging (Optional - for Push Notifications)

1. Go to **Project settings → Cloud Messaging** tab
2. Cloud Messaging is enabled by default
3. For web push notifications, you'll need to:
   - Go to **Web configuration** section
   - Generate a new Web Push certificate (VAPID key)
   - Copy the key pair

---

## Step 8: Deploy Cloud Functions (Optional)

If you want automatic push notifications when schedules change:

```bash
# Navigate to your project
cd /Users/john/Desktop/projects/angular\ +\ firebase/smart_waste_app

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init

# Deploy only Cloud Functions
cd functions
npm install
cd ..
firebase deploy --only functions
```

---

## Step 9: Restart Your App

After updating the config:

```bash
# Stop the current Flutter server (Ctrl+C in terminal)
# Then restart:
flutter run -d chrome --web-port=8080
```

---

## Quick Checklist

- [ ] Firebase project created
- [ ] Email/Password authentication enabled
- [ ] Firestore database created
- [ ] Security rules published
- [ ] 4 zones added to Firestore
- [ ] Web app registered
- [ ] `firebase_options.dart` updated with real values
- [ ] App restarted

---

## Testing Your Setup

1. **Open the app** at http://localhost:8080
2. **Create an account** (Resident or Admin)
3. **Select a zone** from the dropdown (should show 4 zones now)
4. **Login** and verify you see schedules
5. **As Admin**: Try creating a schedule
6. **As Resident**: View your zone's schedules

---

## Troubleshooting

### "FirebaseOptions cannot be null"
→ You haven't updated `firebase_options.dart` with real values

### Zone dropdown is empty
→ Zones collection wasn't created in Firestore, or app wasn't restarted

### "Permission denied" errors
→ Security rules aren't published, or user isn't authenticated

### Authentication failed
→ Email/Password sign-in method isn't enabled in Firebase Console

---

## Need Help?

If you encounter issues, check:
1. Browser console (F12 → Console tab) for errors
2. Firebase Console → Authentication → Users (to verify accounts)
3. Firebase Console → Firestore Database (to verify data)
