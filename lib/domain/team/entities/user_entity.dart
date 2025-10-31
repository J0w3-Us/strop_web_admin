class UserEntity {
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String role; // "admin" o "worker"
  final String phone;
  final bool isActive;
}
