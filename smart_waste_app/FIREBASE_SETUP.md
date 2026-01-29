# Firebase Setup Guide for Smart Waste Collection App

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name your project (e.g., "smart-waste-collection")
4. Enable Google Analytics (optional)
5. Wait for project creation to complete

## Step 2: Enable Firebase Services

### Authentication
1. Go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" provider
3. Click Save

### Cloud Firestore
1. Go to "Firestore Database" → "Create database"
2. Start in production mode
3. Choose your preferred region
4. After creation, go to "Rules" tab and paste the contents of `firestore.rules`

### Cloud Messaging
1. Go to "Project Settings" → "Cloud Messaging"
2. Firebase Cloud Messaging is enabled by default
3. Note your Server Key for testing notifications

## Step 3: Register Apps

### Android
1. Click Android icon in Project Overview
2. Package name: `com.smartwaste.smart_waste_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### iOS
1. Click iOS icon in Project Overview
2. Bundle ID: `com.smartwaste.smartWasteApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### Web
1. Click Web icon in Project Overview
2. Register app with nickname
3. Copy the Firebase config object
4. Update `web/index.html`:

```html
<script type="module">
  import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js';
  
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abc123"
  };
  
  initializeApp(firebaseConfig);
</script>
```

## Step 4: Initialize Sample Data

Create some initial zones in Firestore (Collection: `zones`):

```json
{
  "zoneName": "Downtown District",
  "description": "Central business district area",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "createdAt": Timestamp
}
```

```json
{
  "zoneName": "Residential North",
  "description": "Northern residential neighborhoods",
  "latitude": 12.9816,
  "longitude": 77.6046,
  "createdAt": Timestamp
}
```

## Step 5: Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## Step 6: Run the App

```bash
# For web
flutter run -d chrome

# For Android (requires Android SDK)
flutter run -d android

# For iOS (requires Xcode)
flutter run -d ios
```

## Troubleshooting

### FCM Not Working
- Ensure you've deployed Cloud Functions
- Check that users are subscribed to their zone topic
- Verify FCM is enabled in Firebase Console

### Authentication Errors
- Confirm Email/Password provider is enabled
- Check Firestore security rules are deployed

### Build Errors
- Run `flutter clean && flutter pub get`
- Ensure Firebase config files are in correct locations
