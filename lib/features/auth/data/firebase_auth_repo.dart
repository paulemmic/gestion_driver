import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_driver/features/auth/domain/entites/app_user.dart';
import 'package:gestion_driver/features/auth/domain/repos/auth_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userCredential.user!.displayName ?? "",
      );

      await createUser(user);
      return user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userCredential.user!.displayName ?? "",
      );
      await createUser(user);
      return user;
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception("No user logged in..");
      await user.delete();

      await logout();
    } catch (e) {
      throw Exception("Failed to delete account: $e");
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? "",
    );
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email! check your inbox.";
    } catch (e) {
      return "An error occured: $e";
    }
  }

  @override
  Future<AppUser?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        oAuthCredential,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      AppUser user = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? "",
        name: firebaseUser.displayName ?? "",
      );
      await createUser(user);
      return user;
    } catch (e) {
      print("Error signing in with Apple: $e");
      return null;
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // final GoogleSignInAccount? gUser =
      await googleSignIn.initialize(serverClientId: "YOUR_SERVER");

      final googleSignInAccount = await googleSignIn.authenticate();

      final auth = googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      await createUser(
        AppUser(
          uid: googleSignInAccount.id,
          email: googleSignInAccount.email,
          name: googleSignInAccount.displayName ?? "",
        ),
      );
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Future<void> signOut() async {
  //   try {
  //     await firebaseAuth.signOut();
  //     await googleSignIn.signOut();
  //   } catch (e) {
  //     print("f");
  //   }
  // }

  String? get currentUser {
    final user = firebaseAuth.currentUser;
    return user?.email;
  }

  Future<void> createUser(AppUser user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(user.toJson());
  }
}
