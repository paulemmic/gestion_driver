// features/vehicules/data/services/add_vehicules.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:uuid/uuid.dart';

class AddVehicules {
  static final Uuid _uuid = Uuid();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String _formatKm(int km) {
    if (km >= 1000) return '${(km / 1000).toStringAsFixed(1)}k';
    return km.toString();
  }

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
    final id = 'VH-${_uuid.v4().substring(0, 6).toUpperCase()}';

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
      infoValue: kilometrage != null
          ? '${AddVehicules._formatKm(kilometrage)} km'
          : '0 km',
      infoTone: StatusTone.neutral,
      badgeLabel: statut.toUpperCase(),
      badgeTone: badgeTone,
      complianceStatus: 'Conforme',
      complianceTone: StatusTone.success,
      nextExpiration: '—',
      nextExpirationTone: StatusTone.neutral,
      documents: const [],
      fuelCard: null,
      tollTag: null,
      createdAt: DateTime.now(),
    );
  }

  Future<void> addVehicule(Map<String, dynamic> vehiculeMap, String id) async {
    final collection = firestore.collection('vehicules');
    final duplicateChecks = await Future.wait([
      collection
          .where('plaque', isEqualTo: vehiculeMap['plaque'])
          .limit(1)
          .get(),
      collection.where('vin', isEqualTo: vehiculeMap['vin']).limit(1).get(),
    ]);

    final plaqueSnap = duplicateChecks[0];
    final vinSnap = duplicateChecks[1];

    if (plaqueSnap.docs.isNotEmpty) {
      throw Exception(
        "Un véhicule avec cette plaque d'immatriculation existe déjà.",
      );
    }

    if (vinSnap.docs.isNotEmpty) {
      throw Exception('Un véhicule avec ce numéro VIN existe déjà.');
    }

    await collection.doc(id).set(vehiculeMap);
  }

  Stream<List<Vehicule>> streamAll() {
    return firestore
        .collection('vehicules')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(Vehicule.fromFirestore).toList(growable: false),
        );
  }
}
