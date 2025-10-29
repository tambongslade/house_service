import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final UserModel user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'user': user.toJson()};
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    };
  }
}
