

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAK_UlPHdgIX84XofvSx5Qa0zvgDgS0N38',
    appId: '1:503910090406:web:d8625581e56a8c5b319667',
    messagingSenderId: '503910090406',
    projectId: 'carvex-78a83',
    authDomain: 'carvex-78a83.firebaseapp.com',
    storageBucket: 'carvex-78a83.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_I_rBsRyc6Bx-VHck3blnlNE_TdCIRVM',
    appId: '1:503910090406:android:9c81c35f8b904775319667',
    messagingSenderId: '503910090406',
    projectId: 'carvex-78a83',
    storageBucket: 'carvex-78a83.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSD8ysaSxibUU06nNiVdlpNnvXvULm4L8',
    appId: '1:503910090406:ios:1f13a0356927012a319667',
    messagingSenderId: '503910090406',
    projectId: 'carvex-78a83',
    storageBucket: 'carvex-78a83.firebasestorage.app',
    iosBundleId: 'com.example.carvex',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBSD8ysaSxibUU06nNiVdlpNnvXvULm4L8',
    appId: '1:503910090406:ios:1f13a0356927012a319667',
    messagingSenderId: '503910090406',
    projectId: 'carvex-78a83',
    storageBucket: 'carvex-78a83.firebasestorage.app',
    iosBundleId: 'com.example.carvex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAK_UlPHdgIX84XofvSx5Qa0zvgDgS0N38',
    appId: '1:503910090406:web:03ef93fb8f1eb695319667',
    messagingSenderId: '503910090406',
    projectId: 'carvex-78a83',
    authDomain: 'carvex-78a83.firebaseapp.com',
    storageBucket: 'carvex-78a83.firebasestorage.app',
  );
}
