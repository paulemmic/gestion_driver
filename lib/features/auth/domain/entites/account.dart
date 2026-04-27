class Account {
  final String id; //user_uid
  final String email;
  final String pinCode;
  final String? commune;
  final String? nom;
  final String? quartier;
  final String? telephone;
  final String? ville;

  const Account({
    required this.id,
    required this.email,
    required this.pinCode,
    this.commune,
    this.nom,
    this.quartier,
    this.telephone,
    this.ville,
  });

  Map<String, dynamic> toJson(Account account) {
    return {
      'id': account.id,
      'commune': account.commune,
      'email': account.email,
      'nom': account.nom,
      'quartier': account.quartier,
      'telephone': account.telephone,
      'ville': account.ville,
      'pinCode': account.pinCode,
    };
  }
}
