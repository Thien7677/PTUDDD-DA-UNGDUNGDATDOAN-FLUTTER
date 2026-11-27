import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _role = 'customer';

  User? get user => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get role => _role;
  bool get isOwner => _role == 'owner';

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserRole(user.uid);
      } else {
        _role = 'customer';
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _role = doc.data()!['role']?.toString() ?? 'customer';
      } else {
        _role = 'customer';
      }
    } catch (_) {
      _role = 'customer';
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (cred.user != null) {
        await _loadUserRole(cred.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Đăng nhập thất bại';
    }
  }

  Future<String?> register(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await cred.user?.updateDisplayName(name.trim());
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email.trim(),
        'name': name.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _role = 'customer';
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Đăng ký thất bại';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _role = 'customer';
    notifyListeners();
  }

}