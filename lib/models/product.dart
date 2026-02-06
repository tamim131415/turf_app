import 'package:flutter/material.dart';

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
}
