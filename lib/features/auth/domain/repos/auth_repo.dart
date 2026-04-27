import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_driver/features/auth/domain/entites/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  );
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String?> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<UserCredential?> signInWithGoogle();
  Future<AppUser?> signInWithApple();
}
