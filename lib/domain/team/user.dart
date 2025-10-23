class User {
  User({required this.id, required this.name, this.email, this.role});

  final String id;
  final String name;
  final String? email;
  final String? role;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email, 'role': role};

  static User fromMap(Map m) => User(
    id: m['id']?.toString() ?? '',
    name: m['name']?.toString() ?? '',
    email: m['email']?.toString(),
    role: m['role']?.toString(),
  );
}
