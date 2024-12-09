import 'package:flutter/material.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class _Time extends StatelessWidget {
  final int startTime; //시작 시간
  final int endTime; //종료 시간

  const _Time({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    final textStyle = TextStyle(
      fontWeight: FontWeight.w500,
      color: themeColor,
      fontSize: screenWidth * 0.04,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',
          style: textStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2, '0')}:00',
          style: textStyle.copyWith(
            fontSize: screenWidth * 0.025,
          ),
        )
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content; //내용

  const _Content({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.04,
          ),
        ),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final int startTime;
  final int endTime;
  final String content;
  final double width; // 가로 길이를 받는 매개변수 추가

  const ScheduleCard(
      {required this.startTime,
      required this.endTime,
      required this.content,
      required this.width, // 생성자에 추가
      super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return Container(
      width: screenWidth * width, // 카드의 가로 길이를 설정
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.005,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: screenWidth * 0.003,
          color: themeColor,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Time(startTime: startTime, endTime: endTime),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Expanded(
              child: _Content(content: content),
            ),
          ],
        ),
      ),
    );
  }
}
