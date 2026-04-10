enum UserRole {
  customer,
  admin,
  delivery,
  restaurantOwner;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Super Admin';
      case UserRole.delivery:
        return 'Delivery Partner';
      case UserRole.restaurantOwner:
        return 'Restaurant Owner';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'admin':
        return UserRole.admin;
      case 'delivery':
        return UserRole.delivery;
      case 'restaurantowner':
      case 'restaurant_owner':
        return UserRole.restaurantOwner;
      default:
        return UserRole.customer;
    }
  }
}
