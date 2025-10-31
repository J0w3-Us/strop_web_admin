import 'package:strop_admin_panel/domain/team/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.phone,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'worker',
      phone: json['phone']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'isActive': isActive,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    email: email,
    role: role,
    phone: phone,
    isActive: isActive,
  );
}
