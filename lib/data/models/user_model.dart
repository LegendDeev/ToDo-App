import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? id;
  final String email;
  final String password; // In production, this should be hashed
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert User object to Map for MongoDB
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create User object from MongoDB Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Copy with method for updates
  User copyWith({
    ObjectId? id,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
