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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAi0Qdv9wAZ9MaPoKgJPZ5myyfIbhwm5Dg',
    appId: '1:554357086924:android:111322f427ae9115a08069',
    messagingSenderId: '554357086924',
    projectId: 'rblmalaysia',
    storageBucket: 'rblmalaysia.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAylWmJjfPqD1Nm6dE4biv9VhrIFnGNEY0',
    appId: '1:554357086924:ios:83b1c26413ab6430a08069',
    messagingSenderId: '554357086924',
    projectId: 'rblmalaysia',
    storageBucket: 'rblmalaysia.firebasestorage.app',
    androidClientId: '554357086924-m1ct5o2b9900b0efkjnk1v7v4586gvue.apps.googleusercontent.com',
    iosClientId: '554357086924-jsi71vb72318pcbhd2cp1pfqs7653bvt.apps.googleusercontent.com',
    iosBundleId: 'com.example.rbl',
  );

}