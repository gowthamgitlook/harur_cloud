enum SpiceLevel {
  mild,
  medium,
  spicy;

  String get displayName {
    switch (this) {
      case SpiceLevel.mild:
        return 'Mild';
      case SpiceLevel.medium:
        return 'Medium';
      case SpiceLevel.spicy:
        return 'Spicy';
    }
  }

  String get emoji {
    switch (this) {
      case SpiceLevel.mild:
        return '🌶️';
      case SpiceLevel.medium:
        return '🌶️🌶️';
      case SpiceLevel.spicy:
        return '🌶️🌶️🌶️';
    }
  }

  static SpiceLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'mild':
        return SpiceLevel.mild;
      case 'medium':
        return SpiceLevel.medium;
      case 'spicy':
        return SpiceLevel.spicy;
      default:
        return SpiceLevel.medium;
    }
  }
}
