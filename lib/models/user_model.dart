import 'dart:convert';

enum UserRole {
  user('USER'),
  vip('VIP'),
  admin('ADMIN');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.user,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String username;
  final UserRole role;
  final bool emailVerified;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.emailVerified,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse dates with null safety
    DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
      if (value == null) {
        return defaultValue ?? DateTime.now();
      }
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return defaultValue ?? DateTime.now();
        }
      }
      if (value is DateTime) {
        return value;
      }
      return defaultValue ?? DateTime.now();
    }

    String parsedLocation = '';
    final locationData = json['location'];
    if (locationData != null) {
      if (locationData is String) {
        parsedLocation = locationData;
      } else {
        try {
          parsedLocation = jsonEncode(locationData);
        } catch (_) {
          parsedLocation = locationData.toString();
        }
      }
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'USER'),
      emailVerified: json['emailVerified'] as bool? ?? false,
      location: parsedLocation,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role.value,
      'emailVerified': emailVerified,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    UserRole? role,
    bool? emailVerified,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
