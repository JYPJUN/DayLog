import 'package:daylog_launching/api/api_diary_service.dart';
import 'package:daylog_launching/screens/diary/diary_detail.dart';
import 'package:daylog_launching/screens/footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class DiaryInputWidget extends StatefulWidget {
  final String titleholder;
  final String contextholder;
  final bool update;
  final int diaryId;
  final String? artImagePath;
  final String date;

  const DiaryInputWidget({
    super.key,
    this.titleholder = '제목',
    this.contextholder = '내용을 입력하세요',
    this.update = false,
    this.diaryId = 1,
    this.artImagePath,
    required this.date,
  });

  @override
  State<DiaryInputWidget> createState() => _InputtextState();
}

class _InputtextState extends State<DiaryInputWidget> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _generatedImagePath;
  bool _isLoading = false; // 로딩 상태를 관리하는 변수
  // final bool _isImageLoading = false; // 이미지 로딩 상태를 관리하는 변수

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.update ? widget.titleholder : '');
    _contentController =
        TextEditingController(text: widget.update ? widget.contextholder : '');
  }

  void _submit() async {
    String title = _titleController.text;
    String content = _contentController.text;

    String title2 = _titleController.text.trim(); // 공백 제거
    String content2 = _contentController.text.trim(); // 공백 제거

    // 유효성 검사
    if (title2.isEmpty || content2.isEmpty) {
      _showErrorDialog('제목과 내용을 모두 입력해주세요.');
      return;
    }

    if (title2.length > 12) {
      _showErrorDialog('제목은 12글자를 초과할 수 없습니다.');
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
      FocusScope.of(context).unfocus(); // 키보드 숨기기
    });

    // 이미지 생성 요청
    try {
      _generatedImagePath = await ApiDiaryService.getImage(content);
    } catch (e) {
      _showErrorDialog('이미지 생성에 실패했습니다. 다시 시도해주세요.');
      print(e);
      return;
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }

    _showCompletionDialog(title, content);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 모달 밖을 터치하여 닫을 수 없도록 설정
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);

        return StatefulBuilder(
          // StatefulBuilder 사용하여 setState 가능하도록 설정
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                // Stack 위젯을 사용하여 인디케이터를 가장 상위에 표시
                children: [
                  Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.5,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(237, 237, 237, 10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Text(
                          widget.update ? '그림을 수정하시겠습니까?' : '그림이 완성되었습니다!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Expanded(
                          child: _generatedImagePath != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        _generatedImagePath!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : const Image(
                                  image: AssetImage('assets/drawings/2.jpg'),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  // "아니요" 버튼 동작
                                  if (widget.update) {
                                    setState(() {
                                      _isLoading = true; // 로딩 시작
                                    });

                                    try {
                                      await ApiDiaryService.updateDiary(
                                        widget.diaryId,
                                        title,
                                        content,
                                        widget.artImagePath!,
                                        widget.date,
                                      );
                                    } catch (e) {
                                      _showErrorDialog('일기 업데이트에 실패했습니다.');
                                      return;
                                    } finally {
                                      setState(() {
                                        _isLoading = false; // 로딩 종료
                                      });
                                    }

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiaryDetail(
                                          id: widget.diaryId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(171, 171, 171, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(
                                      screenWidth * 0.3, screenHeight * 0.05),
                                ),
                                child: Text(
                                  widget.update ? '아니요' : '싫어요',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true; // 로딩 시작
                                  });

                                  try {
                                    if (widget.update) {
                                      await ApiDiaryService.updateDiary(
                                        widget.diaryId,
                                        title,
                                        content,
                                        _generatedImagePath.toString(),
                                        widget.date,
                                      );
                                    } else {
                                      await ApiDiaryService.saveDiary(
                                        title,
                                        content,
                                        _generatedImagePath.toString(),
                                        widget.date,
                                      );
                                    }
                                  } catch (e) {
                                    _showErrorDialog('일기 저장 또는 업데이트에 실패했습니다.');
                                    print('오류 내용 : $e');
                                    return;
                                  } finally {
                                    setState(() {
                                      _isLoading = false; // 로딩 종료
                                    });
                                  }

                                  if (widget.update) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiaryDetail(
                                          id: widget.diaryId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Footer(
                                                selectedIndex:
                                                    3, // 일기 페이지로 돌아가도록 footer index 3 지정
                                              )),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.themeColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(
                                      screenWidth * 0.3, screenHeight * 0.05),
                                ),
                                child: _isLoading
                                    ? SpinKitFadingCube(
                                        color: themeProvider.themeColor,
                                        size: screenWidth * 0.06,
                                      )
                                    : Text(
                                        widget.update ? '네' : '좋아요',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                  // 로딩 상태일 때 인디케이터를 화면 중앙에 표시
                  if (_isLoading)
                    Positioned.fill(
                      // Stack의 자식으로 추가하여 모달의 중앙에 표시
                      child: Container(
                        color: Colors.black54, // 반투명 배경 추가
                        child: Center(
                          child: SpinKitFadingCube(
                            color: themeProvider.themeColor,
                            size: 50.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return Stack(
      // Stack 사용하여 전체 화면에 인디케이터와 안내문 표시
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.04),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2 + bottomInset,
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: widget.titleholder,
                        hintStyle: TextStyle(
                          fontSize: screenWidth * 0.06,
                          color: const Color.fromRGBO(171, 171, 171, 1),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: widget.contextholder,
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: const Color.fromRGBO(171, 171, 171, 1),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.04,
                    ),
                    ElevatedButton(
                      onPressed:
                          _isLoading ? null : _submit, // 로딩 중일 때는 버튼 비활성화
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        minimumSize:
                            Size(screenWidth * 0.8, screenHeight * 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? SpinKitFadingCube(
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            )
                          : Text(
                              widget.update ? '수정 완료' : '작성 완료',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) // 로딩 중일 때 인디케이터와 안내문을 화면에 표시
          Positioned.fill(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black54.withOpacity(0.7)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCube(
                    color: themeColor,
                    size: 60.0,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    "잠시만 기다려주세요!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "그림 생성에 20여초가 소요됩니다.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
