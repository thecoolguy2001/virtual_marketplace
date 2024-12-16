// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artwork.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Fetch all artworks
  Stream<List<Artwork>> getArtworks() {
    return _db.collection('Artworks').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList(),
    );
  }
  
  // Fetch featured artworks
  Stream<List<Artwork>> getFeaturedArtworks() {
    return _db.collection('Artworks')
      .where('isFeatured', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList(),
      );
  }
  
  // Fetch trending artists
  Stream<List<UserModel>> getTrendingArtists() {
    // Define your logic for trending (e.g., most sales, most viewed, etc.)
    // For simplicity, let's assume there's a field 'isTrending' in Users collection
    return _db.collection('Users')
      .where('isTrending', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
      );
  }
  
  // Fetch user by ID
  Future<UserModel> getUserById(String userId) async {
    DocumentSnapshot doc = await _db.collection('Users').doc(userId).get();
    return UserModel.fromFirestore(doc);
  }
  // Fetch artworks by artist ID
  Stream<List<Artwork>> getArtworksByArtist(String artistId) {
    return _db.collection('Artworks')
      .where('artistId', isEqualTo: artistId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList(),
      );
  }
  // Add a purchase
  Future<void> addPurchase(Map<String, dynamic> data) async {
    await _db.collection('Purchases').add(data);
    
    // Optionally, update user's purchase history
    await _db.collection('Users').doc(data['buyerId']).update({
      'purchaseHistory': FieldValue.arrayUnion([data['artworkId']])
    });
  }
  // Update user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> data) async {
    await _db.collection('Users').doc(userId).update(data);
  }

  
  // Fetch artworks with filters
  Stream<List<Artwork>> getFilteredArtworks({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? artistId,
  }) {
    CollectionReference collection = _db.collection('Artworks');
    Query query = collection;
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    
    if (artistId != null && artistId.isNotEmpty) {
      query = query.where('artistId', isEqualTo: artistId);
    }
    
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList(),
    );
  }
  
  // Add other Firestore interactions as needed
}