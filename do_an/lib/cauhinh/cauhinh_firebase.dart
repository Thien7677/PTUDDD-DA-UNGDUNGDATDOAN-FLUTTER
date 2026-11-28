import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Các giá trị được truyền bằng --dart-define-from-file=cauhinh_firebase.json.
/// Mỗi nền tảng dùng mã ứng dụng đã đăng ký trong cùng Firebase project.
abstract final class CauHinhFirebase {
  static const maduan = String.fromEnvironment('FIREBASE_MADUAN');
  static const khoaapiweb = String.fromEnvironment('FIREBASE_KHOAAPI_WEB');
  static const khoaapiandroid = String.fromEnvironment(
    'FIREBASE_KHOAAPI_ANDROID',
  );
  static const manguoigui = String.fromEnvironment('FIREBASE_MANGUOIGUI');
  static const maungdungweb = String.fromEnvironment('FIREBASE_MAUNGDUNG_WEB');
  static const maungdungandroid = String.fromEnvironment(
    'FIREBASE_MAUNGDUNG_ANDROID',
  );
  static const miendangnhap = String.fromEnvironment('FIREBASE_MIENDANGNHAP');
  static const kholuutru = String.fromEnvironment('FIREBASE_KHOLUUTRU');
  static const dunggialap = bool.fromEnvironment('FIREBASE_DUNGGIALAP');
  static const maychugialap = String.fromEnvironment(
    'FIREBASE_MAYCHUGIALAP',
    defaultValue: '127.0.0.1',
  );

  static String get maungdung => kIsWeb ? maungdungweb : maungdungandroid;
  static String get khoaapi => kIsWeb ? khoaapiweb : khoaapiandroid;

  static bool get dacauhinh =>
      dunggialap ||
      (maduan.isNotEmpty &&
          khoaapi.isNotEmpty &&
          manguoigui.isNotEmpty &&
          maungdung.isNotEmpty);

  static FirebaseOptions get tuychon => FirebaseOptions(
    apiKey: dunggialap ? 'demo-no-ne-key' : khoaapi,
    appId: dunggialap ? '1:123456789:web:demo' : maungdung,
    messagingSenderId: dunggialap ? '123456789' : manguoigui,
    projectId: dunggialap ? 'demo-no-ne' : maduan,
    storageBucket: dunggialap
        ? 'demo-no-ne.firebasestorage.app'
        : (kholuutru.isEmpty ? null : kholuutru),
    authDomain: dunggialap
        ? 'demo-no-ne.firebaseapp.com'
        : (miendangnhap.isEmpty ? '$maduan.firebaseapp.com' : miendangnhap),
  );
}
