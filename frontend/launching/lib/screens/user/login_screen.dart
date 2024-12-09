import 'package:flutter/material.dart';
import '../../api/api_user_service.dart'; // ApiService import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRememberChecked = false;
  Map<String, dynamic>? userInfo;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  // 자신의 커플 상태 보기
  Future<void> fetchUserInfo() async {
    try {
      final info = await ApiUserService.userInfo();
      setState(() {
        userInfo = info;
      });
    } catch (e) {
      print('Failed to load user info: $e');
    }
  }

  // 이메일 저장
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        isRememberChecked = true; // 저장된 이메일이 있으면 체크박스를 체크 상태로 설정
      });
    }
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final responseData = await ApiUserService.login(email, password);
      final token = responseData['accessToken'];

      if (token != null && token.isNotEmpty) {
        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // Remember 체크박스 상태에 따라 이메일 저장
        if (isRememberChecked) {
          await prefs.setString('saved_email', email);
        } else {
          await prefs.remove('saved_email');
        }

        // 사용자 정보 가져오기
        await fetchUserInfo();

        // 사용자 정보의 status에 따라 페이지 이동
        if (userInfo != null) {
          final status = userInfo!['status'];
          if (status == 'ACTIVE') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (Route<dynamic> route) => false,
            );
          } else if (status == 'PENDING') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/loading',
              (Route<dynamic> route) => false,
            );
          } else if (status == 'INACTIVE') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/connect',
              (Route<dynamic> route) => false,
            );
          }
        } else {
          _showErrorDialog('로그인 정보를 다시 확인해주세요.');
        }
      } else {
        _showErrorDialog('로그인에 실패했습니다. 다시 시도하세요.');
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      _showErrorDialog('로그인 정보를 다시 확인해주세요.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로그인 실패'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    late Color themeColor;
    late Color backColor;

    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    String logoAsset;

    // 테마 색상에 따라 로고 선택
    if (themeColor == const Color(0xFFff9292)) {
      logoAsset = 'assets/logo/Logo1.png';
    } else if (themeColor == const Color(0xFFc796fc)) {
      logoAsset = 'assets/logo/Logo2.png';
    } else if (themeColor == const Color(0xFF87ceeb)) {
      logoAsset = 'assets/logo/Logo4.png';
    } else {
      logoAsset = 'assets/logo/Logo3.png'; // 기본 로고
    }

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logoAsset,
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isRememberChecked,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        setState(() {
                          isRememberChecked = newValue;
                        });
                      }
                    },
                    activeColor: themeColor,
                  ),
                  const SizedBox(width: 5), // 체크박스와 텍스트 사이 간격 조정
                  const Text('Remember'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login, // 로그인 버튼 클릭 시 _login 함수 호출
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: themeColor,
                  minimumSize: const Size(400, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(color: themeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
