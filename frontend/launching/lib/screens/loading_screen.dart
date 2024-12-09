import 'package:daylog_launching/api/api_user_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

import '../screens/couple/couple_connect_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _showThreeDots = false;
  Timer? _dotTimer;
  String? coupleCode;
  String? coupleStatus;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _fetchCoupleCode();
    _checkCoupleStatus();
  }

  void _startDotAnimation() {
    _dotTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      if (mounted) {
        setState(() {
          _showThreeDots = !_showThreeDots;
        });
      }
    });
  }

  // 커플 코드 관리
  Future<void> _fetchCoupleCode() async {
    try {
      final coupleCodeInfo = await ApiUserService.userInfo();
      setState(() {
        coupleCode = coupleCodeInfo['coupleCode'];
      });
    } catch (e) {
      print('Failed to load user info: $e');
    }
  }

  // 커플 상태 관리
  void _checkCoupleStatus() {
    _statusCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      try {
        final coupleStatusInfo = await ApiUserService.userInfo();
        setState(() async {
          coupleStatus = coupleStatusInfo['status'];
          if (coupleStatus == 'ACTIVE') {
            await ApiUserService.getNewToken();
            _navigateToHome(); // 홈으로 이동
          }
        });
      } catch (e) {
        print('Failed to check status..: $e');
      }
    });
  }

  void _navigateToHome() {
    _statusCheckTimer?.cancel(); // 상태 체크 타이머 해제
    Navigator.pushReplacementNamed(context, '/home'); // /home으로 네비게이트
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  // 뒤로가기
  void _onBackButtonPressed() {
    ApiUserService.coupleStatusReplace();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CoupleConnectScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // 최소 높이를 화면 크기로 설정
            maxHeight: MediaQuery.of(context).size.height, // 최대 높이를 화면 크기로 설정
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/imgs/videocall.png',
                fit: BoxFit.cover,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 30,
                          color: Color(0xFFFFABAB),
                        ),
                        onPressed: _onBackButtonPressed,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 콘텐츠를 수직으로 가운데 정렬
                        children: [
                          SizedBox(
                            width: 200, // 크기 제한
                            height: 200, // 크기 제한
                            child: Lottie.asset(
                              'assets/anime/cat1.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (coupleCode != null) ...[
                            Text(
                              '나의 커플 코드: $coupleCode',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ] else ...[
                            const CircularProgressIndicator(),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            _showThreeDots
                                ? '상대방의 연결을 기다리고 있습니다...'
                                : '상대방의 연결을 기다리고 있습니다..',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 91, 91, 91),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
