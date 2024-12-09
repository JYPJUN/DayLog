import 'package:daylog_launching/api/api_calendar_service.dart';
import 'package:daylog_launching/widgets/colors.dart';
import 'package:daylog_launching/widgets/calendar/custom_text_field.dart';
import 'package:flutter/material.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate; // selectedDate 추가

  const ScheduleBottomSheet({
    super.key,
    required this.selectedDate, // 생성자에 추가
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheet();
}

class _ScheduleBottomSheet extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey(); //폼키 생성
  int? startTime; //시작 시간 저장 변수
  int? endTime; // 종료 시간 저장 변수
  String? content; //일정 내용 저장 변수

  bool isMe = true; // 'ME' 스위치 상태, 디폴트값을 true로 설정
  bool isYou = false; // 'YOU' 스위치 상태

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return Form(
      key: formKey,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              )),
          height: MediaQuery.of(context).size.height / 2 +
              bottomInset, // ➋ 화면 반 높이에 키보드 높이 추가하기
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.03,
              right: screenWidth * 0.03,
              top: screenHeight * 0.01,
              bottom: bottomInset,
            ),
            child: Column(
              // ➋ 시간 관련 텍스트 필드와 내용 관련 텍스트 필드 세로로 배치
              children: [
                Row(
                  // ➊ 시작 시간 종료 시간 가로로 배치
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: '시작 시간',
                        isTime: true,
                        onSaved: (String? val) {
                          startTime = int.parse(val!);
                        },
                        validator: timeValidator,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: CustomTextField(
                        label: '종료 시간',
                        isTime: true,
                        onSaved: (String? val) {
                          endTime = int.parse(val!);
                        },
                        validator: timeValidator,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Expanded(
                  child: CustomTextField(
                    label: '내용',
                    isTime: false,
                    onSaved: (String? val) {
                      content = val;
                    },
                    validator: contentValidator,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // 참여자 선택 스위치
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_rounded,
                      color: DARK_GREY_COLOR,
                    ),
                    SizedBox(
                      width: screenWidth * 0.01,
                    ),
                    Text(
                      '참가자 : ',
                      style: TextStyle(
                        color: DARK_GREY_COLOR,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.08,
                    ),
                    Row(
                      children: [
                        Text(
                          'ME',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Switch(
                          value: isMe,
                          onChanged: (value) {
                            setState(() {
                              isMe = value;
                            });
                          },
                          activeColor: themeColor,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: screenWidth * 0.05,
                    ),
                    Row(
                      children: [
                        Text(
                          'YOU',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Switch(
                          value: isYou,
                          onChanged: (value) {
                            setState(() {
                              isYou = value;
                            });
                          },
                          activeColor: themeColor,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // [저장] 버튼
                    onPressed: onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSavePressed() async {
    late String type;
    late bool isMine;

    if (formKey.currentState!.validate()) {
      // ➊ 폼 검증하기
      formKey.currentState!.save(); // ➋ 폼 저장하기

      // 시간 검증
      if (startTime! > endTime!) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류'),
            content: const Text('시작 시간이 종료 시간보다 느립니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // isMe와 isYou에 따른 type 및 isMine 설정
    if (isMe && !isYou) {
      type = 'PERSONAL';
      isMine = true;
    } else if (!isMe && isYou) {
      type = 'PERSONAL';
      isMine = false;
    } else if (isMe && isYou) {
      type = 'SHARED';
      isMine = true;
    } else {
      // 기본값 설정 (필요한 경우에만)
      type = 'PERSONAL';
      isMine = true;
    }

    // 날짜를 "YYYY-MM-DD" 형식으로 변환
    String formattedDate =
        '${widget.selectedDate.year.toString().padLeft(4, '0')}-'
        '${widget.selectedDate.month.toString().padLeft(2, '0')}-'
        '${widget.selectedDate.day.toString().padLeft(2, '0')}';

    try {
      await ApiCalendarService.saveDiary(
        type,
        content!,
        formattedDate,
        startTime!,
        endTime!,
        isMine, // isMine,
      );

      Navigator.of(context).pop(true); // BottomSheet 닫기

      // 일정 데이터 갱신 요청
      // 예: Provider, Bloc 또는 setState() 등을 사용하여 갱신
    } catch (e) {
      print('Failed to save schedule: $e');
      // 오류 처리 로직 추가 가능
    }
  }

  String? timeValidator(String? val) {
    if (val == null) {
      return '시간을 입력해주세요';
    }

    int? number;

    try {
      number = int.parse(val);
    } catch (e) {
      return '숫자를 입력해주세요';
    }

    if (number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;
  } // 시간값 검증

  String? contentValidator(String? val) {
    if (val == null || val.isEmpty) {
      return '내용을 입력해주세요';
    }

    if (val.length > 50) {
      return '내용은 50자 이하로 입력해주세요';
    }

    return null;
  } // 내용값 검증
}
