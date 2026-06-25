class DocumentType {
  final String id;
  final String vehiculeId;
  final String? numeroDocument;
  final DateTime? dateEmission;
  final DateTime? dateExpiration;
  final String? fichierUrl;
  final String? fichierNom;

  const DocumentType({
    required this.id,
    required this.vehiculeId,
    this.numeroDocument,
    this.dateEmission,
    this.dateExpiration,
    this.fichierUrl,
    this.fichierNom,
  });
}
