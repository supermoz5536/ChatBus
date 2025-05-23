// 注意: システムファイルなので安易に編集しないように!
// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDt3J_890UBZVIB3dM_JhsRg3j_4WJvyXk',
    appId: '1:704666938065:web:f2b7241683c5d1df1633f0',
    messagingSenderId: '704666938065',
    projectId: 'udemy-882f1',
    authDomain: 'udemy-882f1.firebaseapp.com',
    storageBucket: 'udemy-882f1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoL57cO9_Yp982TnbKzosw1L11EjRK-3c',
    appId: '1:704666938065:android:0185ac65f7a1bef01633f0',
    messagingSenderId: '704666938065',
    projectId: 'udemy-882f1',
    storageBucket: 'udemy-882f1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtSdozZi_x44hG13QvD12RqRVonsxzUpE',
    appId: '1:704666938065:ios:d8a34961f6df852e1633f0',
    messagingSenderId: '704666938065',
    projectId: 'udemy-882f1',
    storageBucket: 'udemy-882f1.appspot.com',
    iosBundleId: 'com.example.udemyCopy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDtSdozZi_x44hG13QvD12RqRVonsxzUpE',
    appId: '1:704666938065:ios:595ec87403817dd71633f0',
    messagingSenderId: '704666938065',
    projectId: 'udemy-882f1',
    storageBucket: 'udemy-882f1.appspot.com',
    iosBundleId: 'com.example.udemyCopy.RunnerTests',
  );
}
