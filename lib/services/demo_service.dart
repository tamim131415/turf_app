import 'package:flutter/material.dart';
import '../models/product.dart';

class DemoService {
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'Argentina World Cup Jersey 2022',
        price: 3499.0,
        originalPrice: 3999.0,
        team: 'Argentina',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.8,
        reviewCount: 124,
        isFavorite: true,
        sizes: ['S', 'M', 'L', 'XL'],
        colors: [Colors.blue, Colors.white],
        description:
            'Official Argentina World Cup 2022 Jersey. Made with 100% recycled materials.',
      ),
      Product(
        id: '2',
        name: 'Brazil Home Kit 2023',
        price: 3299.0,
        team: 'Brazil',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=2',
        rating: 4.6,
        reviewCount: 89,
        isFavorite: false,
        sizes: ['M', 'L', 'XL'],
        colors: [Colors.yellow, Colors.green],
        description:
            'Brazil National Team Home Kit 2023. Lightweight and breathable.',
      ),
      Product(
        id: '3',
        name: 'Germany Away Jersey',
        price: 2999.0,
        team: 'Germany',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.4,
        reviewCount: 67,
        isFavorite: false,
        sizes: ['S', 'M', 'L'],
        colors: [Colors.black, Colors.white],
        description:
            'Germany Away Jersey with advanced moisture-wicking technology.',
      ),
      Product(
        id: '4',
        name: 'Nike Mercurial Superfly',
        price: 12999.0,
        team: 'Nike',
        category: 'Shoes',
        imageUrl: 'https://picsum.photos/200/300?random=4',
        rating: 4.9,
        reviewCount: 203,
        isFavorite: true,
        sizes: ['8', '9', '10', '11'],
        colors: [Colors.orange, Colors.black],
        description:
            'Nike Mercurial Superfly Elite FG. Designed for speed and precision.',
      ),
      Product(
        id: '5',
        name: 'Portugal Away Kit 2023',
        price: 2899.0,
        team: 'Portugal',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=5',
        rating: 4.5,
        reviewCount: 78,
        isFavorite: false,
        sizes: ['S', 'M', 'L', 'XL'],
        colors: [Colors.red, Colors.green],
        description: 'Portugal National Team Away Kit 2023.',
      ),
      Product(
        id: '6',
        name: 'Adidas Predator',
        price: 11999.0,
        team: 'Adidas',
        category: 'Shoes',
        imageUrl: 'https://picsum.photos/200/300?random=6',
        rating: 4.7,
        reviewCount: 156,
        isFavorite: true,
        sizes: ['7', '8', '9', '10'],
        colors: [Colors.black, Colors.white],
        description:
            'Adidas Predator Accuracy. Designed for control and precision.',
      ),
    ];
  }
}
