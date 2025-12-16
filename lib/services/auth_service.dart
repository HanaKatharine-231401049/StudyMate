// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Make sure this is configured correctly in Android/iOS project and Firebase console
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isSignedIn => currentUser != null;

  // ---------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<String?> signInWithGoogle() async {
    try {
      // 1) Pick Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // user closed the dialog
        return 'Proses Google Sign-In dibatalkan.';
      }

      // 2) Get Google auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        return 'Token Google tidak ditemukan.';
      }

      // 3) Build Firebase credential & sign in
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return 'Gagal masuk dengan Google.';

      final uid = user.uid;
      final email = user.email ?? '';
      final displayName = user.displayName?.trim();
      final phoneNumber = user.phoneNumber ?? '';
      final photoUrl = user.photoURL; // optional, can be used in UI

      // Derive a username if none
      final localPart =
          email.contains('@') ? email.split('@')[0] : (displayName ?? 'user');
      final username = localPart;
      final fullName =
          (displayName != null && displayName.isNotEmpty) ? displayName : localPart;

      // 4) Create or update Firestore user doc
      final docRef = _db.collection('users').doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // New user
        await docRef.set({
          'uid': uid,
          'username': username,
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          // optional: store photoUrl (network URL) in addition to your base64 scheme
          if (photoUrl != null) 'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Existing user -> update basic info & updatedAt
        await docRef.update({
          'username': username,
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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

  // ---------------------------------------------------------------------------
  // EMAIL/PASSWORD SIGN-UP
  // ---------------------------------------------------------------------------
  Future<String?> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? photoBase64, // optional profile picture stored as base64
  }) async {
    try {
      // 1) Create auth user
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'Gagal membuat user.';

      // 2) Set displayName in FirebaseAuth (optional but nice)
      await user.updateDisplayName(fullName);

      final uid = user.uid;

      // 3) Create user doc in Firestore
      final data = <String, dynamic>{
        'uid': uid,
        'username': username,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        if (photoBase64 != null && photoBase64.isNotEmpty)
          'photoBase64': photoBase64,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(uid).set(data);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('signUp error: $e');
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  // ---------------------------------------------------------------------------
  // EMAIL/PASSWORD SIGN-IN
  // ---------------------------------------------------------------------------
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthExceptionToMessage(e);
    } catch (e) {
      if (kDebugMode) print('signIn error: $e');
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN-OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // ignore Google sign-out errors
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PASSWORD RESET
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // ERROR MAPPING
  // ---------------------------------------------------------------------------
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
