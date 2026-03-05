import 'package:flutter/material.dart';

enum FoodCategory {
  biryani,
  friedRice,
  parotta,
  grill,
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
      case FoodCategory.drinks:
        return Icons.local_drink;
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
      case 'drinks':
        return FoodCategory.drinks;
      default:
        return FoodCategory.biryani;
    }
  }
}
