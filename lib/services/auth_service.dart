// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // GoogleSignIn instance (mobile). clientId biasanya tidak perlu diisi untuk Android.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
    // clientId: '<YOUR_CLIENT_ID_IF_NEEDED_FOR_IOS_OR_WEB>',
  );

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isSignedIn => currentUser != null;

  /// Sign in menggunakan Google (mendukung kIsWeb + mobile)
  /// Jika forceAccountSelection = true, akan memaksa tampilan account chooser:
  /// - web: menggunakan custom parameter 'prompt': 'select_account'
  /// - mobile: melakukan signOut() terlebih dahulu untuk memaksa chooser
  ///
  /// Mengembalikan null jika sukses, atau string error jika gagal.
  Future<String?> signInWithGoogle({bool forceAccountSelection = true}) async {
    try {
      // ------------------ WEB FLOW ------------------
      if (kIsWeb) {
        final provider = GoogleAuthProvider();

        // minta Google selalu menampilkan account chooser
        if (forceAccountSelection) {
          provider.setCustomParameters({'prompt': 'select_account'});
        }

        final userCredential = await _auth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) return 'Gagal masuk dengan Google (web).';

        // buat dokumen user jika belum ada
        final doc = await _firestore.getUser(user.uid);
        if (!doc.exists) {
          await _firestore.createUser(
            uid: user.uid,
            name: user.displayName ?? (user.email?.split('@')[0] ?? 'User'),
            email: user.email ?? '',
            photoUrl: user.photoURL,
          );
        }
        notifyListeners();
        return null;
      }

      // ------------------ MOBILE FLOW ------------------
      // Jika ingin memaksa tampil chooser, bersihkan sesi googleSignIn terlebih dahulu.
      if (forceAccountSelection) {
        try {
          await _googleSignIn.signOut();
          // jangan disconnect() secara default kecuali Anda ingin revoke access.
        } catch (_) {
          // ignore
        }
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Proses Google Sign-In dibatalkan oleh pengguna.';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if ((idToken == null || idToken.isEmpty) && (accessToken == null || accessToken.isEmpty)) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        return 'Token Google tidak ditemukan. Pastikan konfigurasi Google Sign-In benar.';
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) return 'Gagal masuk dengan Google.';

      final doc = await _firestore.getUser(user.uid);
      if (!doc.exists) {
        await _firestore.createUser(
          uid: user.uid,
          name: user.displayName ?? (user.email?.split('@')[0] ?? 'User'),
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FirebaseAuthException signInWithGoogle: ${e.code} ${e.message}');
      return e.message ?? 'Terjadi kesalahan autentikasi Firebase saat Google Sign-In.';
    } catch (e, st) {
      if (kDebugMode) print('Exception signInWithGoogle: $e\n$st');
      try {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (_) {}
      return 'Terjadi kesalahan saat proses Google Sign-In: ${e.toString()}';
    }
  }

  /// Sign in dengan email & password
  /// Return null jika sukses, atau pesan error jika gagal
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = uc.user;
      if (user == null) return 'Gagal sign in: user tidak ditemukan.';
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FirebaseAuthException signIn: ${e.code} ${e.message}');
      // Buat pesan yang ramah
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar.';
        case 'wrong-password':
          return 'Password salah.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun dinonaktifkan.';
        default:
          return e.message ?? 'Terjadi kesalahan saat sign in.';
      }
    } catch (e, st) {
      if (kDebugMode) print('Exception signIn: $e\n$st');
      return 'Terjadi kesalahan saat sign in.';
    }
  }

  /// Sign up (create user) dengan email & password. Kembalikan null bila sukses.
  Future<String?> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final UserCredential uc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = uc.user;
      if (user == null) return 'Gagal membuat akun.';
      // Update displayName bila tersedia
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
      // Buat dokumen user di Firestore
      await _firestore.createUser(
        uid: user.uid,
        name: name ?? user.email?.split('@')[0] ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FirebaseAuthException signUp: ${e.code} ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'weak-password':
          return 'Password terlalu lemah (minimal 6 karakter).';
        default:
          return e.message ?? 'Terjadi kesalahan saat membuat akun.';
      }
    } catch (e, st) {
      if (kDebugMode) print('Exception signUp: $e\n$st');
      return 'Terjadi kesalahan saat membuat akun.';
    }
  }

  /// Kirim email reset password
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FirebaseAuthException sendPasswordResetEmail: ${e.code} ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return e.message ?? 'Terjadi kesalahan saat mengirim email reset.';
      }
    } catch (e, st) {
      if (kDebugMode) print('Exception sendPasswordResetEmail: $e\n$st');
      return 'Terjadi kesalahan saat mengirim email reset.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}
    notifyListeners();
  }
}