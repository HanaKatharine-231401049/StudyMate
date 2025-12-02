// lib/services/auth_service.dart  (compatible with google_sign_in ^5.4.0)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isSignedIn => currentUser != null;

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Proses Google Sign-In dibatalkan.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        return 'Token Google tidak ditemukan.';
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return 'Gagal masuk dengan Google.';

      final doc = await _firestore.getUser(user.uid);
      if (!doc.exists) {
        await _firestore.createUser(
          uid: user.uid,
          name: user.displayName ?? (user.email?.split('@')[0] ?? 'User'),
          email: user.email ?? '',
        );
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('Google sign-in error: $e');
      return 'Terjadi kesalahan saat proses Google Sign-In.';
    }
  }

  // ... other methods (signUp, signIn, signOut, sendPasswordReset, _mapAuthExceptionToMessage)
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return 'Gagal membuat user.';
      await user.updateDisplayName(name);
      await _firestore.createUser(uid: user.uid, name: name, email: email);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('signUp error: $e');
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('signIn error: $e');
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    notifyListeners();
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('sendPasswordReset error: $e');
      return 'Terjadi kesalahan saat mengirim email reset.';
    }
  }

  String _mapAuthExceptionToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun dinonaktifkan.';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah dipakai.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
}