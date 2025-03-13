import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

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
    apiKey: 'AIzaSyBHov69SYGB7YBSgdlRQYvSKop62mFHaHM',
    appId: '1:208080088446:android:192113bfb18f4805ab572f',
    messagingSenderId: '208080088446',
    projectId: 'ah-market-5ab28',
    databaseURL: 'https://ah-market-5ab28-default-rtdb.firebaseio.com',
    storageBucket: 'ah-market-5ab28.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHov69SYGB7YBSgdlRQYvSKop62mFHaHM',
    appId: '1:208080088446:android:192113bfb18f4805ab572f',
    messagingSenderId: '208080088446',
    projectId: 'ah-market-5ab28',
    databaseURL: 'https://ah-market-5ab28-default-rtdb.firebaseio.com',
    storageBucket: 'ah-market-5ab28.appspot.com',
    androidClientId:
        '208080088446-ta38l05u8vqsgtrjufqtmnqg55c85qo5.apps.googleusercontent.com',
    iosClientId: '',
    iosBundleId: '',
  );
}
