import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration options for Smart Waste Collection App
/// Project: waste-management-9aecb
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmluqx5v4seIHrUACzQ9zpORtYYAP-W90',
    appId: '1:609744897468:web:2fef857b56411ccfa5d7b9',
    messagingSenderId: '609744897468',
    projectId: 'waste-management-9aecb',
    authDomain: 'waste-management-9aecb.firebaseapp.com',
    storageBucket: 'waste-management-9aecb.firebasestorage.app',
    measurementId: 'G-616DX7WZKX',
  );

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmluqx5v4seIHrUACzQ9zpORtYYAP-W90',
    appId: '1:609744897468:web:2fef857b56411ccfa5d7b9',
    messagingSenderId: '609744897468',
    projectId: 'waste-management-9aecb',
    storageBucket: 'waste-management-9aecb.firebasestorage.app',
  );

  // iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmluqx5v4seIHrUACzQ9zpORtYYAP-W90',
    appId: '1:609744897468:web:2fef857b56411ccfa5d7b9',
    messagingSenderId: '609744897468',
    projectId: 'waste-management-9aecb',
    storageBucket: 'waste-management-9aecb.firebasestorage.app',
    iosBundleId: 'com.smartwaste.smartWasteApp',
  );
}
