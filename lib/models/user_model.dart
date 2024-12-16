// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String profilePicture;
  final List<String> portfolio;
  final List<String> purchaseHistory;
  final bool isTrending;
  final String? bio; // Added bio field

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profilePicture,
    required this.portfolio,
    required this.purchaseHistory,
    required this.isTrending,
    this.bio,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Buyer',
      profilePicture: data['profilePicture'] ?? '',
      portfolio: List<String>.from(data['portfolio'] ?? []),
      purchaseHistory: List<String>.from(data['purchaseHistory'] ?? []),
      isTrending: data['isTrending'] ?? false,
      bio: data['bio'], // Assign bio if available
    );
  }
}