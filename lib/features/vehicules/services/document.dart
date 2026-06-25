// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
// import 'package:gestion_driver/shared/models/status_tone.dart';

// class DocumentServiceException implements Exception {
//   const DocumentServiceException(this.message);
//   final String message;

//   @override
//   String toString() => 'DocumentServiceException: $message';
// }

// class DocumentService {
//   DocumentService({FirebaseFirestore? firestore})
//     : firestore = firestore ?? FirebaseFirestore.instance;

//   final FirebaseFirestore firestore;

//   CollectionReference<Map<String, dynamic>> documentsRef(String vehiculeId) =>
//       firestore.collection('vehicules').doc(vehiculeId).collection('documents');

//   Future<String> addDocument({
//     required String vehiculeId,
//     required VehiculeDocument document,
//   }) async {
//     try {
//       final ref = await documentsRef(vehiculeId).add(toFirestore(document));
//       return ref.id;
//     } on FirebaseException catch (e) {
//       throw DocumentServiceException(
//         'Erreur Firebase lors de l\'ajout : ${e.message}',
//       );
//     }
//   }

//   Future<List<VehiculeDocument>> fetchDocuments(String vehiculeId) async {
//     try {
//       final snapshot = await documentsRef(
//         vehiculeId,
//       ).orderBy('createdAt', descending: true).get();

//       return snapshot.docs.map((doc) => fromFirestore(doc.data())).toList();
//     } on FirebaseException catch (e) {
//       throw DocumentServiceException(
//         'Erreur Firebase lors de la récupération : ${e.message}',
//       );
//     }
//   }

//   Future<void> updateDocument({
//     required String vehiculeId,
//     required String firestoreId,
//     required VehiculeDocument document,
//   }) async {
//     try {
//       await documentsRef(
//         vehiculeId,
//       ).doc(firestoreId).update(toFirestore(document));
//     } on FirebaseException catch (e) {
//       throw DocumentServiceException(
//         'Erreur Firebase lors de la mise à jour : ${e.message}',
//       );
//     } catch (e) {
//       throw DocumentServiceException(
//         'Erreur inconnue lors de la mise à jour : $e',
//       );
//     }
//   }

//   Future<void> deleteDocument({
//     required String vehiculeId,
//     required String firestoreId,
//   }) async {
//     try {
//       await documentsRef(vehiculeId).doc(firestoreId).delete();
//     } on FirebaseException catch (e) {
//       throw DocumentServiceException(
//         'Erreur Firebase lors de la suppression : ${e.message}',
//       );
//     }
//   }

//   Stream<List<VehiculeDocument>> streamDocuments(String vehiculeId) {
//     return documentsRef(vehiculeId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map(
//           (snapshot) =>
//               snapshot.docs.map((doc) => fromFirestore(doc.data())).toList(),
//         );
//   }

//   Map<String, dynamic> toFirestore(VehiculeDocument doc) => {
//     'iconCodePoint': doc.icon.codePoint,
//     'iconFontFamily': doc.icon.fontFamily ?? 'MaterialIcons',
//     'title': doc.title,
//     'subtitle': doc.subtitle,
//     'status': doc.status,
//     'tone': doc.tone.name,
//     'extra': doc.extra,
//     'extraTone': doc.extraTone.name,
//     'createdAt': FieldValue.serverTimestamp(),
//     'dateExpiration': doc.dateExpiration != null
//         ? Timestamp.fromDate(doc.dateExpiration!)
//         : null,
//   };

//   VehiculeDocument fromFirestore(Map<String, dynamic> data) {
//     DateTime? dateExpiration = (data['dateExpiration'] as Timestamp?)?.toDate();
//     if (dateExpiration == null){
//       final extra = (data['extra'] as String?) ?? '';
//       dateExpiration = _parseDateFromExtra(extra);
//     })
//       return VehiculeDocument(
//             icon: IconData(
//       (data['iconCodePoint'] as int?) ?? 0xe22b,
//       fontFamily: (data['iconFontFamily'] as String?) ?? 'MaterialIcons',
//     ),

//         title: (data['title'] as String?) ?? '',
//       subtitle: (data['subtitle'] as String?) ?? '',
//       status: (data['status'] as String?) ?? '',
//       tone: _parseTone(data['tone'] as String?),
//       extra: (data['extra'] as String?) ?? '',
//       extraTone: _parseTone(data['extraTone'] as String?),
//       dateExpiration: dateExpiration,
//       );
//   }
// }

// DateTime? _parseDateFromExtra(String extra) {
//   final parts = extra.trim().split('/');
//   if (parts.length != 3) return null;
//   final day = int.tryParse(parts[0]);
//   final month = int.tryParse(parts[1]);
//   final year = int.tryParse(parts[2]);
//   if (day == null || month == null || year == null) return null;
//   try {
//     return DateTime(year, month, day);
//   } catch (_) {
//     return null;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class DocumentServiceException implements Exception {
  const DocumentServiceException(this.message);
  final String message;

  @override
  String toString() => 'DocumentServiceException: $message';
}

class DocumentService {
  DocumentService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> documentsRef(String vehiculeId) =>
      firestore.collection('vehicules').doc(vehiculeId).collection('documents');

  Future<String> addDocument({
    required String vehiculeId,
    required VehiculeDocument document,
  }) async {
    try {
      final ref = await documentsRef(vehiculeId).add(toFirestore(document));
      return ref.id;
    } on FirebaseException catch (e) {
      throw DocumentServiceException(
        'Erreur Firebase lors de l\'ajout : ${e.message}',
      );
    }
  }

  Future<List<VehiculeDocument>> fetchDocuments(String vehiculeId) async {
    try {
      final snapshot = await documentsRef(
        vehiculeId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => fromFirestore(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw DocumentServiceException(
        'Erreur Firebase lors de la récupération : ${e.message}',
      );
    }
  }

  Future<void> updateDocument({
    required String vehiculeId,
    required String firestoreId,
    required VehiculeDocument document,
  }) async {
    try {
      await documentsRef(
        vehiculeId,
      ).doc(firestoreId).update(toFirestore(document, deleteLegacyExtra: true));
    } on FirebaseException catch (e) {
      throw DocumentServiceException(
        'Erreur Firebase lors de la mise à jour : ${e.message}',
      );
    } catch (e) {
      throw DocumentServiceException(
        'Erreur inconnue lors de la mise à jour : $e',
      );
    }
  }

  Future<void> deleteDocument({
    required String vehiculeId,
    required String firestoreId,
  }) async {
    try {
      await documentsRef(vehiculeId).doc(firestoreId).delete();
    } on FirebaseException catch (e) {
      throw DocumentServiceException(
        'Erreur Firebase lors de la suppression : ${e.message}',
      );
    }
  }

  Stream<List<VehiculeDocument>> streamDocuments(String vehiculeId) {
    return documentsRef(vehiculeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => fromFirestore(doc.data())).toList(),
        );
  }

  Map<String, dynamic> toFirestore(
    VehiculeDocument doc, {
    bool deleteLegacyExtra = false,
  }) {
    final data = <String, dynamic>{
      'iconCodePoint': doc.icon.codePoint,
      'iconFontFamily': doc.icon.fontFamily ?? 'MaterialIcons',
      'title': doc.title,
      'subtitle': doc.subtitle,
      'status': doc.status,
      'tone': doc.tone.name,
      'extraTone': doc.extraTone.name,
      'createdAt': FieldValue.serverTimestamp(),
      'dateExpiration': doc.dateExpiration != null
          ? Timestamp.fromDate(doc.dateExpiration!)
          : null,
    };

    if (deleteLegacyExtra) {
      data['extra'] = FieldValue.delete();
    }

    return data;
  }

  VehiculeDocument fromFirestore(Map<String, dynamic> data) {
    final legacyExtra = (data['extra'] as String?) ?? '';
    final dateExpiration =
        _readDateExpiration(data['dateExpiration']) ??
        _parseDateFromExtra(legacyExtra);

    return VehiculeDocument(
      icon: IconData(
        (data['iconCodePoint'] as int?) ?? 0xe22b,
        fontFamily: (data['iconFontFamily'] as String?) ?? 'MaterialIcons',
      ),
      title: (data['title'] as String?) ?? '',
      subtitle: (data['subtitle'] as String?) ?? '',
      status: (data['status'] as String?) ?? '',
      tone: _parseTone(data['tone'] as String?),
      extra: legacyExtra.isNotEmpty ? legacyExtra : _formatDate(dateExpiration),
      extraTone: _parseTone(data['extraTone'] as String?),
      dateExpiration: dateExpiration,
    );
  }

  DateTime? _readDateExpiration(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return _parseDateFromExtra(raw);
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime? _parseDateFromExtra(String extra) {
    final parts = extra.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  StatusTone _parseTone(String? raw) => switch (raw) {
    'success' => StatusTone.success,
    'warning' => StatusTone.warning,
    'danger' => StatusTone.danger,
    _ => StatusTone.neutral,
  };
}
