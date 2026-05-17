import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9aeD94-WWpXJuKlxQ43V4xm93B8dKuw8',
    appId: '1:658997155851:android:723beebf89a61dcda48f0e',
    messagingSenderId: '658997155851',
    projectId: 'harur-cloud',
    storageBucket: 'harur-cloud.firebasestorage.app',
    androidClientId: '658997155851-a6bm6gqbtpakio6u1vvmu1ql89kpghqe.apps.googleusercontent.com',
  );

  // Replace with real iOS config once iOS app is registered in Firebase console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9aeD94-WWpXJuKlxQ43V4xm93B8dKuw8',
    appId: '1:658997155851:ios:000000000000000000000000',
    messagingSenderId: '658997155851',
    projectId: 'harur-cloud',
    storageBucket: 'harur-cloud.firebasestorage.app',
    iosClientId: '',
    iosBundleId: 'com.harur.cloudkitchen',
  );

  // Replace with real web config once web app is registered in Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9aeD94-WWpXJuKlxQ43V4xm93B8dKuw8',
    appId: '1:658997155851:web:000000000000000000000000',
    messagingSenderId: '658997155851',
    projectId: 'harur-cloud',
    storageBucket: 'harur-cloud.firebasestorage.app',
    authDomain: 'harur-cloud.firebaseapp.com',
  );
}
