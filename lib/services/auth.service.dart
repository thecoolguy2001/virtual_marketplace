// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of authentication state
  Stream<User?> get user => _auth.authStateChanges();

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = 
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      debugPrint('Sign Up Error: $e');
      return null;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = 
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      debugPrint('Sign In Error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}