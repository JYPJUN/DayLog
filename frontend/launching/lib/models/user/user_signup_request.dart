class UserSignupRequest {
  final String email;
  final String password;
  final String name;
  final String tel;
  final DateTime birthDate;

  UserSignupRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.tel,
    required this.birthDate,
  });

  // JSON 데이터를 UserSignupRequest 객체로 변환하는 factory 생성자
  factory UserSignupRequest.fromJson(Map<String, dynamic> json) {
    return UserSignupRequest(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      tel: json['tel'],
      birthDate: DateTime.parse(json['birthDate']),
    );
  }

  // UserSignupRequest 객체를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'tel': tel,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}
