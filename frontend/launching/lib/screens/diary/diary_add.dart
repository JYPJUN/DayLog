import 'package:daylog_launching/widgets/diary_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class DiaryAdd extends StatefulWidget {
  const DiaryAdd({super.key});

  @override
  State<DiaryAdd> createState() => _DiaryAddScreenState();
}

class _DiaryAddScreenState extends State<DiaryAdd> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        selectedDate;
    if (picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 변수명 설정
    late Color themeColor;
    late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.01,
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.lightBlue,
                          size: screenWidth * 0.08,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.07,
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.045,
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: screenWidth * 0.9,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.03),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '사랑하는 사람과의 하루를 기록해보세요',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '당신의 하루를 멋진 그림으로 돌려드립니다!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DiaryInputWidget(
                date: DateFormat('yyyy-MM-dd').format(selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
