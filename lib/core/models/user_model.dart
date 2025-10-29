enum UserRole { serviceProvider, serviceSeeker }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.serviceProvider:
        return 'provider';
      case UserRole.serviceSeeker:
        return 'seeker';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'provider':
        return UserRole.serviceProvider;
      case 'seeker':
        return UserRole.serviceSeeker;
      default:
        return UserRole.serviceSeeker; // Default fallback
    }
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final UserRole? role;
  final String? phoneNumber;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.phoneNumber,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role:
          json['role'] != null
              ? UserRoleExtension.fromString(json['role'])
              : null,
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role?.value,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getter for display name
  String get displayName => fullName;
}
