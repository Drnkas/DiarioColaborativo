class SignUpDto {

  const SignUpDto({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullName,
      'email': email,
      'password': password,
    };
  }
}