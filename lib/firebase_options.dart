import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwxmGY19QcjvxPQ76h40rvXjk3n6zhnMs',
    authDomain: 'apis-e3fb8.firebaseapp.com',
    projectId: 'apis-e3fb8',
    storageBucket: 'apis-e3fb8.firebasestorage.app',
    messagingSenderId: '259165233493',
    appId: '1:259165233493:web:9b6cfa13fd1184369fcfdc',
  );
}