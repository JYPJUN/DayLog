import 'package:flutter/material.dart';
import '../../api/api_user_service.dart';
import '../../service/validation_service.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordconfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isEmailChecked = false;
  bool isPhoneChecked = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkEmailDuplicate() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력해주세요')),
      );
      return;
    } else if (!ValidationService.isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('(예: id@ssafy.com) 형식으로 입력해주세요.')),
      );
      return;
    }

    try {
      final isDuplicate = await ApiUserService.checkEmailDuplicate(email);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 이메일입니다')),
        );
        setState(() {
          isEmailChecked = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 이메일입니다')),
        );
        setState(() {
          isEmailChecked = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 중복 검사 중 오류가 발생했습니다')),
      );
      setState(() {
        isEmailChecked = false;
      });
    }
  }

  Future<void> checkPhoneDuplicate() async {
    final phone = _phoneController.text;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('핸드폰번호를 입력해주세요.')),
      );
      return;
    } else if (!ValidationService.isPhoneValid(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('핸드폰번호 11자리를 입력해주세요.')),
      );
      return;
    }

    try {
      final isDuplicate = await ApiUserService.checkPhoneDuplicate(phone);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 번호입니다')),
        );
        setState(() {
          isPhoneChecked = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 번호입니다')),
        );
        setState(() {
          isPhoneChecked = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('번호 중복 검사 중 오류가 발생했습니다')),
      );
      setState(() {
        isPhoneChecked = false;
      });
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _passwordconfirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 다릅니다')),
        );
        return;
      }

      if (!isEmailChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 중복 검사를 완료해주세요')),
        );
        return;
      }

      if (!isPhoneChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('번호 중복검사를 완료해주세요')),
        );
        return;
      }

      final userSignUpRequest = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'birthDate': '1990-01-01', // 예시로 지정된 생년월일
      };

      try {
        await ApiUserService.signUp(userSignUpRequest);
        Navigator.pushNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late Color themeColor;
    late Color backColor;

    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // 뒤로가기 화살표 색상
        ),
        title: const Text(
          'DayLog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff333333)),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  labelText: '이메일',
                  hintText: '(예: id@ssafy.com)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!ValidationService.isEmailValid(value)) {
                      return '(예: id@ssafy.com) 형식으로 입력해주세요.';
                    }
                    return null;
                  },
                  icon: IconButton(
                    icon: const Icon(Icons.check_circle_outlined),
                    onPressed: checkEmailDuplicate,
                    color: isEmailChecked ? themeColor : themeColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  labelText: '비밀번호',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (!ValidationService.isPasswordValid(value)) {
                      return '비밀번호는 최소 6자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordconfirmController,
                  labelText: '비밀번호 확인',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  labelText: '이름(별명)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _phoneController,
                  labelText: '핸드폰 번호',
                  hintText: '\'-\'를 제외하고 입력해주세요.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '핸드폰 번호를 입력해주세요';
                    }
                    if (!ValidationService.isPhoneValid(value)) {
                      return '올바른 형식의 핸드폰 번호를 입력해주세요 (11자리 숫자)';
                    }
                    return null;
                  },
                  icon: IconButton(
                    icon: const Icon(Icons.check_circle_outlined),
                    onPressed: checkPhoneDuplicate,
                    color: isPhoneChecked ? themeColor : themeColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50, // 높이를 줄이기 위해 변경
                  width: 400, // 너비를 줄이기 위해 설정
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: themeColor,
                      minimumSize: const Size(100, 50), // 최소 크기 설정
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10), // 패딩 조정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('회원가입'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    required String? Function(String?) validator,
    Widget? icon,
  }) {
    late Color themeColor;
    late Color backColor;

    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return SizedBox(
      height: 70,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFEDEDED)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: themeColor),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 241, 213, 213)),
              borderRadius: BorderRadius.circular(12)),
          suffixIcon: icon,
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
