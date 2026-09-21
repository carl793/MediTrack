// Generated from google-services.json
// Project: meditrack-firebase
// DO NOT commit API keys to public repos — move to environment variables for production.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'MediTrack does not support Web. Configure a web app in Firebase Console if needed.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS not configured yet. Add GoogleService-Info.plist and update this file.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmsDAASkvliz-MxBcTkAScx2ysBEn92PY',
    appId: '1:406372831708:android:1de841d9321f1e8eb97f19',
    messagingSenderId: '406372831708',
    projectId: 'meditrack-firebase',
    databaseURL:
        'https://meditrack-firebase-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'meditrack-firebase.firebasestorage.app',
  );
}
