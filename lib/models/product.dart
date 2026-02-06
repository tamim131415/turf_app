import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String team;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final List<String> sizes;
  final List<Color> colors;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.team,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavorite = false,
    required this.sizes,
    required this.colors,
    required this.description,
  });

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'team': team,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
      'sizes': sizes,
      'colors': colors.map((color) => color.value).toList(),
      'description': description,
    };
  }

  // Create Product from Firestore Map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      team: map['team'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      sizes: List<String>.from(map['sizes'] ?? []),
      colors:
          (map['colors'] as List<dynamic>?)
              ?.map((colorValue) => Color(colorValue))
              .toList() ??
          [],
      description: map['description'] ?? '',
    );
  }

  // Create Product from Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Product.fromMap(map, doc.id);
  }
}
