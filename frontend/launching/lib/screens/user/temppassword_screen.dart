import 'package:flutter/material.dart';

class TemppasswordScreen extends StatelessWidget {
  const TemppasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DayLog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFABAB), // 원하는 배경색으로 변경
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '임시 비밀번호 입니다',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(40), // 박스 내부 여백
                decoration: BoxDecoration(
                  color: Colors.white, // 박스 배경 색상
                  borderRadius: BorderRadius.circular(12), // 박스 모서리 둥글게
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '123456', // 임시 비밀번호 텍스트
                      style: TextStyle(
                        fontSize: 24, // 폰트 크기
                        fontWeight: FontWeight.bold, // 폰트 굵기
                      ),
                    ),
                    SizedBox(height: 10), // 텍스트 사이의 간격
                    Text(
                      '*안전을 위해 비밀번호를 변경해 주세요', // 안내 문구
                      style: TextStyle(
                        fontSize: 12, // 폰트 크기
                        color: Colors.red, // 텍스트 색상
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFFFABAB),
                  minimumSize: const Size(400, 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 15), // 내부 여백 지정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 모서리 반경 지정
                  ), // 텍스트 색상 지정
                ),
                child: const Text('로그인 화면으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
