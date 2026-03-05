enum UserRole {
  customer,
  admin,
  delivery;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Admin';
      case UserRole.delivery:
        return 'Delivery Partner';
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
      default:
        return UserRole.customer;
    }
  }
}
