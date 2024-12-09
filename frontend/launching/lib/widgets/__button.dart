import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color foreColor;
  final Color backColor;
  final dynamic width;

  const ButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    required this.foreColor,
    required this.backColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // 너비를 화면에 맞게 설정
      child: ElevatedButton(
        onPressed: onPressed, // 전달된 콜백 함수 사용
        style: ElevatedButton.styleFrom(
          foregroundColor: foreColor,
          backgroundColor: backColor, // 버튼의 배경 색상
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 버튼의 모서리 둥글기
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
