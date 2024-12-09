import 'package:flutter/material.dart';

class FindpasswordScreen extends StatelessWidget {
  const FindpasswordScreen({super.key});

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold), // 원하는 텍스트 스타일 적용
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white, // 배경 색상 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // 모서리 반경 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFFFFFFF)), // 활성화 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFEDEDED)), // 포커스 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: Colors.white, // 배경 색상 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // 모서리 반경 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFFFFFFF)), // 활성화 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFEDEDED)), // 포커스 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.white, // 배경 색상 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // 모서리 반경 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFFFFFFF)), // 활성화 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFFEDEDED)), // 포커스 상태일 때 테두리 색상
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/temppassword');
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
              child: const Text('제출하기'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Enjoy DayLog!',
              style: TextStyle(color: Color(0xFFFFABAB)),
            ),
          ],
        ),
      ),
    );
  }
}
