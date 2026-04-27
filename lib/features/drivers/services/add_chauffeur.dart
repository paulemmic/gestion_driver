import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:uuid/uuid.dart';

class AddChauffeur {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> chauffeur(
    Map<String, dynamic> chauffeurInfoMap,
    String id,
  ) async {
    return await firestore
        .collection('chauffeurs')
        .doc(id)
        .set(chauffeurInfoMap);
  }

  Chauffeur buildFromForm({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String numeroCin,
    required String numeroPermis,
    required String categoriePermis,
    required String statut,
    DateTime? dateNaissance,
    DateTime? dateExpirationPermis,
    DateTime? dateExpirationVisite,
    String? photoUrl,
  }) {
    final id = 'FA-${const Uuid().v4().substring(0, 4).toUpperCase()}';
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 30));

    // Calcul alerte
    ChauffeurAlert alert;
    bool conforme = true;

    if (dateExpirationPermis != null && dateExpirationPermis.isBefore(now)) {
      conforme = false;
      alert = const ChauffeurAlert(
        label: 'PERMIS EXPIRÉ',
        value: 'EXPIRÉ',
        tone: StatusTone.danger,
        icon: Icons.error_outline,
      );
    } else if (dateExpirationPermis != null &&
        dateExpirationPermis.isBefore(soon)) {
      final days = dateExpirationPermis.difference(now).inDays;
      alert = ChauffeurAlert(
        label: 'EXPIRATION DU PERMIS',
        value: '$days JOURS',
        tone: StatusTone.danger,
        icon: Icons.warning_amber_rounded,
      );
    } else if (dateExpirationVisite != null &&
        dateExpirationVisite.isBefore(soon)) {
      final days = dateExpirationVisite.difference(now).inDays;
      alert = ChauffeurAlert(
        label: 'VISITE MÉDICALE',
        value: '$days JOURS',
        tone: StatusTone.warning,
        icon: Icons.timer_outlined,
      );
    } else {
      alert = const ChauffeurAlert(
        label: 'TOUS CONFORMES',
        value: 'OK',
        tone: StatusTone.success,
        icon: Icons.check_circle_outline,
      );
    }

    return Chauffeur(
      id: id,
      name: '$prenom $nom',
      photoUrl: photoUrl,
      conforme: conforme,
      alert: alert,
      metrics: const [],
      documents: const [],
      telephone: telephone,
      email: email,
      numeroCin: numeroCin,
      numeroPermis: numeroPermis,
      categoriePermis: categoriePermis,
      statut: statut,
      dateNaissance: dateNaissance,
      dateExpirationPermis: dateExpirationPermis,
      dateExpirationVisite: dateExpirationVisite,
      createdAt: now,
    );
  }

  Future<void> updateChauffeur(
    String id,
    Map<String, dynamic> chauffeurInfoMap,
  ) async {
    await firestore.collection('chauffeurs').doc(id).set(
      chauffeurInfoMap,
      SetOptions(merge: true),
    );
  }

  Future<String> uploadPhoto({
    required String chauffeurId,
    required File file,
  }) async {
    final photoRef = storage.ref().child(
      'chauffeurs/$chauffeurId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadTask = await photoRef.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<String> updateChauffeurPhoto({
    required String chauffeurId,
    required File file,
  }) async {
    final photoUrl = await uploadPhoto(chauffeurId: chauffeurId, file: file);
    await updateChauffeur(chauffeurId, {
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return photoUrl;
  }

  // ─── Stream temps réel ─────────────────────────────────────────────────────
  Stream<List<Chauffeur>> streamAll() {
    return firestore
        .collection('chauffeurs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Chauffeur.fromFirestore).toList());
  }
}
