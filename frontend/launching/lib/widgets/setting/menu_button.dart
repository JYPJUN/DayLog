import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color themeColor;

  const MenuButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeColor.withOpacity(0.2), // 위쪽은 연한 색
            themeColor, // 아래쪽은 짙은 색
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 버튼 배경색을 흰색으로 설정
          foregroundColor: themeColor, // 아이콘 및 텍스트 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 모서리 반경 설정
            side: const BorderSide(color: Colors.transparent), // 버튼 보더 투명 처리
          ),
          shadowColor: themeColor, // 그림자 색상을 테마 컬러로 설정
          elevation: 3, // 그림자 깊이 설정
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30.0,
              color: themeColor, // 아이콘 색상 설정
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 20, color: Colors.black38), // 텍스트 색상 설정
              textAlign: TextAlign.center, // 텍스트 가운데 정렬
            ),
          ],
        ),
      ),
    );
  }
}
