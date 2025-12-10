// lib/utils/firebase_helper.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  
  static String? get userEmail => FirebaseAuth.instance.currentUser?.email;
  
  static String? get userName => FirebaseAuth.instance.currentUser?.displayName;
  
  // Helper untuk konversi date string ke DateTime
  static DateTime? parseDateString(String dateString) {
    try {
      final parts = dateString.trim().split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _monthFromName(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }
  
  static int _monthFromName(String name) {
    switch (name.toLowerCase()) {
      case 'january': return 1;
      case 'february': return 2;
      case 'march': return 3;
      case 'april': return 4;
      case 'may': return 5;
      case 'june': return 6;
      case 'july': return 7;
      case 'august': return 8;
      case 'september': return 9;
      case 'october': return 10;
      case 'november': return 11;
      case 'december': return 12;
      default: return 1;
    }
  }
  
  static String formatDate(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}