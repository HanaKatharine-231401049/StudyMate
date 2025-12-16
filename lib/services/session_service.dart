import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final _db = FirebaseFirestore.instance;

  Future<String> createSession({
    required String title,
    required String subject,
    required String ownerId,
    required DateTime startsAt,
    required int durationMin,
    required bool isPublic,
  }) async {
    final doc = await _db.collection('study_sessions').add({
      'title': title,
      'subject': subject,
      'ownerId': ownerId,
      'startsAt': Timestamp.fromDate(startsAt),
      'durationMin': durationMin,
      'isPublic': isPublic,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
