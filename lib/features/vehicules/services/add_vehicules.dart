// features/vehicules/data/services/add_vehicules.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:uuid/uuid.dart';

class AddVehicules {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ─── Formatage kilométrage ─────────────────────────────────────────────────
  static String _formatKm(int km) {
    if (km >= 1000) return '${(km / 1000).toStringAsFixed(1)}k';
    return km.toString();
  }

  // ─── Construction depuis le formulaire ────────────────────────────────────
  Vehicule buildFromForm({
    required String marque,
    required String modele,
    required String plaque,
    required String vin,
    required int annee,
    int? kilometrage,
    required String carburant,
    required String statut,
    String? notes,
  }) {
    final id = 'VH-${const Uuid().v4().substring(0, 6).toUpperCase()}';

    final StatusTone badgeTone = switch (statut) {
      'En maintenance' => StatusTone.danger,
      'Inactif' => StatusTone.neutral,
      _ => StatusTone.success,
    };

    return Vehicule(
      id: id,
      name: '$marque $modele',
      plaque: plaque.toUpperCase(),
      marque: marque,
      modele: modele,
      vin: vin.toUpperCase(),
      annee: annee,
      kilometrage: kilometrage,
      carburant: carburant,
      statut: statut,
      notes: notes,
      infoLabel: 'Kilométrage',
      infoValue: kilometrage != null ? '${_formatKm(kilometrage)} km' : '0 km',
      infoTone: StatusTone.neutral,
      badgeLabel: statut.toUpperCase(),
      badgeTone: badgeTone,
      complianceStatus: 'Conforme',
      complianceTone: StatusTone.success,
      nextExpiration: '—',
      nextExpirationTone: StatusTone.neutral,
      documents: const [],
      fuelCard: const FuelCardInfo(
        status: '—',
        tone: StatusTone.neutral,
        subtitle: '—',
        expiry: '—',
      ),
      tollTag: const TollTagInfo(
        status: '—',
        tone: StatusTone.neutral,
        subtitle: '—',
        issue: '—',
        actionLabel: '—',
      ),
      createdAt: DateTime.now(),
    );
  }

  Future<void> addVehicule(Map<String, dynamic> vehiculeMap, String id) async {
    // Doublon plaque
    final plaqueSnap = await firestore
        .collection('vehicules')
        .where('plaque', isEqualTo: vehiculeMap['plaque'])
        .limit(1)
        .get();

    if (plaqueSnap.docs.isNotEmpty) {
      throw Exception(
        "Un véhicule avec cette plaque d'immatriculation existe déjà.",
      );
    }

    // Doublon VIN
    final vinSnap = await firestore
        .collection('vehicules')
        .where('vin', isEqualTo: vehiculeMap['vin'])
        .limit(1)
        .get();

    if (vinSnap.docs.isNotEmpty) {
      throw Exception('Un véhicule avec ce numéro VIN existe déjà.');
    }

    await firestore.collection('vehicules').doc(id).set(vehiculeMap);
  }

  // ─── Stream temps réel ─────────────────────────────────────────────────────
  Stream<List<Vehicule>> streamAll() {
    return firestore
        .collection('vehicules')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Vehicule.fromFirestore).toList());
  }
}
