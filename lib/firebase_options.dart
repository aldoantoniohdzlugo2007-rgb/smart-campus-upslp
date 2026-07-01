import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDgyMwuwimaOm7WjrWomusCqqjer5518RY',
      appId: '1:1077805077348:web:2fb996fc9b5e8d4c126071',
      messagingSenderId: '1077805077348',
      projectId: 'app-trafico-v2',
      authDomain: 'app-trafico-v2.firebaseapp.com',
      storageBucket: 'app-trafico-v2.firebasestorage.app',
    );
  }
}