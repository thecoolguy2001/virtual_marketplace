// lib/models/artwork.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Artwork {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final String artistId;
  final String currency;
  final bool isFeatured;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.artistId,
    required this.currency,
    required this.isFeatured,
  });

  factory Artwork.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Artwork(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      artistId: data['artistId'] ?? '',
      currency: data['currency'] ?? 'USD',
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}