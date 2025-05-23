// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAz3MzU7ZraZHfyTyxSvlx8RIMotwIbLYo',
    appId: '1:862517015998:web:087ed4a0f9546f8b86f5ef',
    messagingSenderId: '862517015998',
    projectId: 'playthefut',
    authDomain: 'playthefut.firebaseapp.com',
    storageBucket: 'playthefut.firebasestorage.app',
    measurementId: 'G-CS2MKR7T9N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYUUj70VZAKQ5DyxVhTWxQzb77DayBO28',
    appId: '1:862517015998:android:41b533d57f2c41a586f5ef',
    messagingSenderId: '862517015998',
    projectId: 'playthefut',
    storageBucket: 'playthefut.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAztcL5S4GiegY249J-6oXWRIFs5lZbICw',
    appId: '1:862517015998:ios:2d7008677746719f86f5ef',
    messagingSenderId: '862517015998',
    projectId: 'playthefut',
    storageBucket: 'playthefut.firebasestorage.app',
    iosBundleId: 'com.example.playthefit',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAztcL5S4GiegY249J-6oXWRIFs5lZbICw',
    appId: '1:862517015998:ios:2d7008677746719f86f5ef',
    messagingSenderId: '862517015998',
    projectId: 'playthefut',
    storageBucket: 'playthefut.firebasestorage.app',
    iosBundleId: 'com.example.playthefit',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAz3MzU7ZraZHfyTyxSvlx8RIMotwIbLYo',
    appId: '1:862517015998:web:5f1a7c9eba4878fc86f5ef',
    messagingSenderId: '862517015998',
    projectId: 'playthefut',
    authDomain: 'playthefut.firebaseapp.com',
    storageBucket: 'playthefut.firebasestorage.app',
    measurementId: 'G-Q23Q3D3KCR',
  );
}
