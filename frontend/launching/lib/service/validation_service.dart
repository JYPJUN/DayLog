class ValidationService {
  // 이메일 형식 검사 정규식
  static final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // 이메일 형식 검사 메서드
  static bool isEmailValid(String email) {
    return _emailRegExp.hasMatch(email);
  }

  // 예시: 비밀번호 유효성 검사 (최소 6자 이상)
  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  // 예시: 핸드폰 번호 유효성 검사 (11자리 숫자)
  static bool isPhoneValid(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^\d{11}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
}
