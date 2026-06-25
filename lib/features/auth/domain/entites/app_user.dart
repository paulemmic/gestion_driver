class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? role;
  final String? phone;
  final String? licenseNumber;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.role,
    this.phone,
    this.licenseNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'licenseNumber': licenseNumber,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
      role: jsonUser['role'],
      phone: jsonUser['phone'],
      licenseNumber: jsonUser['licenseNumber'],
    );
  }
}
