import 'package:flutter/material.dart';

enum FoodCategory {
  biryani,
  friedRice,
  parotta,
  grill,
  starters,
  drinks;

  String get displayName {
    switch (this) {
      case FoodCategory.biryani:
        return 'Biryani';
      case FoodCategory.friedRice:
        return 'Fried Rice';
      case FoodCategory.parotta:
        return 'Parotta';
      case FoodCategory.grill:
        return 'Grill';
      case FoodCategory.starters:
        return 'Starters';
      case FoodCategory.drinks:
        return 'Drinks';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodCategory.biryani:
        return Icons.rice_bowl;
      case FoodCategory.friedRice:
        return Icons.restaurant;
      case FoodCategory.parotta:
        return Icons.flatware;
      case FoodCategory.grill:
        return Icons.outdoor_grill;
      case FoodCategory.starters:
        return Icons.fastfood;
      case FoodCategory.drinks:
        return Icons.local_drink;
    }
  }

  Color get color {
    switch (this) {
      case FoodCategory.biryani:
        return const Color(0xFFFF6B00); // Orange
      case FoodCategory.friedRice:
        return const Color(0xFF4CAF50); // Green
      case FoodCategory.parotta:
        return const Color(0xFFFFC107); // Amber
      case FoodCategory.grill:
        return const Color(0xFFF44336); // Red
      case FoodCategory.starters:
        return const Color(0xFFE91E63); // Pink
      case FoodCategory.drinks:
        return const Color(0xFF2196F3); // Blue
    }
  }

  String get iconPath {
    switch (this) {
      case FoodCategory.biryani:
        return 'assets/icons/biryani.svg';
      case FoodCategory.friedRice:
        return 'assets/icons/fried_rice.svg';
      case FoodCategory.parotta:
        return 'assets/icons/parotta.svg';
      case FoodCategory.grill:
        return 'assets/icons/grill.svg';
      case FoodCategory.starters:
        return 'assets/icons/starters.svg';
      case FoodCategory.drinks:
        return 'assets/icons/drinks.svg';
    }
  }

  static FoodCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'biryani':
        return FoodCategory.biryani;
      case 'friedrice':
      case 'fried rice':
        return FoodCategory.friedRice;
      case 'parotta':
        return FoodCategory.parotta;
      case 'grill':
        return FoodCategory.grill;
      case 'starters':
        return FoodCategory.starters;
      case 'drinks':
        return FoodCategory.drinks;
      default:
        return FoodCategory.biryani;
    }
  }
}
