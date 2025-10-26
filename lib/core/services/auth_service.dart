import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class AuthServices {
  Future<User?> loginWithEmailAndPassword(String email, String password);
  Future<User?> registerWithEmailAndPassword(String email, String password);
  User? currentUser();
  Future<void> logOut();
  // Future<bool> signInWithGoogle();
}

class AuthServicesImpl implements AuthServices {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  User? currentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth Error: ${e.code} - ${e.message}");
      rethrow; // يترمي لـ cubit يتعامل معاه
    }
  }

  @override
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  @override
  Future<void> logOut() async {
    // await GoogleSignIn( ).signOut();

    await _firebaseAuth.signOut();
  }
}
