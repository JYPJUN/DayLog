import 'package:flutter/material.dart';
import '../../api/api_user_service.dart';
import '../../api/api_couple_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class CoupleConnectScreen extends StatefulWidget {
  const CoupleConnectScreen({super.key});

  @override
  State<CoupleConnectScreen> createState() => _CoupleConnectScreenState();
}

class _CoupleConnectScreenState extends State<CoupleConnectScreen> {
  Map<String, dynamic>? userInfo;
  final TextEditingController _invitecodeController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
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

  // 로그아웃 메서드
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  Future<void> submitCoupleCode() async {
    final code = _invitecodeController.text;
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '초대 코드를 입력해주세요.';
      });
      return;
    }

    try {
      final success = await ApiCoupleService.coupleCode(code);
      if (success) {
        // 성공적으로 커플 코드가 등록된 경우, 사용자 정보를 다시 가져옴
        await fetchUserInfo();
        if (userInfo != null && userInfo!['status'] == 'PENDING') {
          // 사용자가 입력한 커플 코드가 맞는경우, 로딩 화면으로 이동
          Navigator.pushNamed(context, '/loading');
        } else if (userInfo!['status'] == 'ACTIVE') {
          await ApiUserService.getNewToken();
          Navigator.pushNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = '유효한 코드가 아닙니다.';
          });
        }
      } else {
        setState(() {
          _errorMessage = '커플 코드 등록에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '코드가 맞지 않는 것 같아요, 다른 코드를 입력해보세요!: $e';
      });
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
        leading: IconButton(
          icon: const Icon(
            Icons.logout_outlined,
            color: Colors.white,
          ),
          onPressed: () async {
            await _signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (Route<dynamic> route) => false,
            ); // 로그인 화면으로 이동
          },
        ),
        title: const Text(
          '짝꿍 데려오기',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor, // 원하는 배경색으로 변경
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (userInfo != null) ...[
              Text(
                '나의 커플 코드: ${userInfo!['coupleCode'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16),
              ),
            ] else ...[
              const CircularProgressIndicator(),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _invitecodeController,
              decoration: InputDecoration(
                hintText: '초대코드 입력',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFEDEDED)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
            ],
            ElevatedButton(
              onPressed: submitCoupleCode,
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
              child: const Text('제출하기'),
            ),
          ],
        ),
      ),
    );
  }
}
