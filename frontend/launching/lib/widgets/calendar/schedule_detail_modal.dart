import 'package:flutter/material.dart';
import 'package:daylog_launching/api/api_calendar_service.dart';
import 'package:daylog_launching/widgets/colors.dart';
import 'package:daylog_launching/widgets/calendar/custom_text_field.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class Scheduledetailmodal extends StatefulWidget {
  final int id, startTime, endTime;
  final String type, content, date;
  final bool isMine;

  const Scheduledetailmodal({
    super.key,
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.content,
    required this.date,
    required this.isMine,
  });

  @override
  State<Scheduledetailmodal> createState() => _ScheduledetailmodalState();
}

class _ScheduledetailmodalState extends State<Scheduledetailmodal> {
  final GlobalKey<FormState> formKey = GlobalKey(); // 폼키 생성
  late int startTime;
  late int endTime;
  late String content;
  late bool isMe;
  late bool isYou;
  bool isEditMode = false; // 수정 모드 여부

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    startTime = widget.startTime;
    endTime = widget.endTime;
    content = widget.content;
    isMe = widget.isMine;

    // type에 따라 isYou를 설정
    if (widget.type == 'SHARED') {
      isMe = true;
      isYou = true;
    } else if (widget.type == 'PERSONAL') {
      isYou = !widget.isMine;
    }
  }

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
            ),
          ),
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.03,
              right: screenWidth * 0.03,
              top: screenHeight * 0.01,
              bottom: bottomInset,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditMode ? '일정 수정' : '일정 상세',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.05,
                          color: themeColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isEditMode
                                  ? Icons.calendar_month_outlined
                                  : Icons.edit,
                              color: themeColor,
                              size: screenWidth * 0.08,
                            ),
                            onPressed: () {
                              setState(() {
                                isEditMode = !isEditMode; // 수정 모드 토글
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey,
                              size: screenWidth * 0.08,
                            ),
                            onPressed:
                                _showDeleteConfirmationDialog, // 삭제 확인 다이얼로그 호출
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: '시작 시간',
                        isTime: true,
                        initialValue: startTime.toString(),
                        onSaved: (String? val) {
                          startTime = int.parse(val!);
                        },
                        validator: timeValidator,
                        enabled: isEditMode, // 수정 모드에 따라 활성화 여부 결정
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: CustomTextField(
                        label: '종료 시간',
                        isTime: true,
                        initialValue: endTime.toString(),
                        onSaved: (String? val) {
                          endTime = int.parse(val!);
                        },
                        validator: timeValidator,
                        enabled: isEditMode, // 수정 모드에 따라 활성화 여부 결정
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Expanded(
                  child: CustomTextField(
                    label: '내용',
                    isTime: false,
                    initialValue: content,
                    onSaved: (String? val) {
                      content = val!;
                    },
                    validator: contentValidator,
                    enabled: isEditMode, // 수정 모드에 따라 활성화 여부 결정
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_rounded,
                      color: DARK_GREY_COLOR,
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    Text(
                      '참가자 : ',
                      style: TextStyle(
                        color: DARK_GREY_COLOR,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: screenHeight * 0.05),
                    Row(
                      children: [
                        Text(
                          'ME',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: screenHeight * 0.01),
                        Switch(
                          value: isMe,
                          onChanged: isEditMode
                              ? (value) {
                                  setState(() {
                                    isMe = value;
                                  });
                                }
                              : null,
                          activeColor: themeColor,
                        ),
                      ],
                    ),
                    SizedBox(width: screenHeight * 0.02),
                    Row(
                      children: [
                        Text(
                          'YOU',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: screenHeight * 0.01),
                        Switch(
                          value: isYou,
                          onChanged: isEditMode
                              ? (value) {
                                  setState(() {
                                    isYou = value;
                                  });
                                }
                              : null,
                          activeColor: themeColor,
                        ),
                      ],
                    ),
                  ],
                ),
                if (isEditMode)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onUpdatePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Text(
                        '수정',
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

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete message',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          '이 일정을 삭제하시겠습니까?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.grey)),
            child: const Text(
              "취소",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
          TextButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(themeProvider.themeColor)),
            onPressed: () async {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              await _deleteSchedule(); // 일정 삭제 함수 호출
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 일정 삭제
  Future<void> _deleteSchedule() async {
    try {
      await ApiCalendarService.deleteSchedule(widget.id.toString());
      Navigator.of(context).pop(true); // 모달 닫기 후 이전 화면으로 돌아가기
    } catch (e) {
      print('Failed to delete schedule: $e');
      // 오류 처리 로직 추가 가능
    }
  }

  void onUpdatePressed() async {
    late String type;
    late bool isMine;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // 시간 검증
      if (startTime > endTime) {
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

      // 업데이트할 필드 구성
      final Map<String, dynamic> updatedFields = {
        "type": type,
        "date": widget.date,
        "content": content,
        "startTime": startTime,
        "endTime": endTime,
        "isMine": isMine,
      };

      try {
        await ApiCalendarService.updateSchedule(
            widget.id.toString(), updatedFields);
        Navigator.of(context).pop(true); // BottomSheet 닫기

        // 일정 데이터 갱신 요청
      } catch (e) {
        print('Failed to update schedule: $e');
        // 오류 처리 로직 추가 가능
      }
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
