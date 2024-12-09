import 'package:daylog_launching/api/api_diary_service.dart';
import 'package:daylog_launching/models/diary/diary_model.dart';
import 'package:daylog_launching/screens/diary/diary_update.dart';
import 'package:daylog_launching/screens/footer.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DiaryDetail extends StatefulWidget {
  final int id;

  const DiaryDetail({
    super.key,
    required this.id,
  });

  @override
  State<DiaryDetail> createState() => _DiaryDetailState();
}

class _DiaryDetailState extends State<DiaryDetail> {
  late Future<DiaryModel> diary;

  @override
  void initState() {
    super.initState();
    diary = ApiDiaryService.getDiary(widget.id);
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy년 MM월 dd일').format(dateTime);
  }

  Future<void> _saveImageToDevice(String imagePath) async {
    try {
      // Android 13 이상에서는 READ_MEDIA_IMAGES 권한이 필요
      if (Platform.isAndroid && await _isAndroid13OrAbove()) {
        var mediaImagesPermission = await Permission.photos.request();
        if (!mediaImagesPermission.isGranted) {
          _showErrorDialog('저장소 권한이 필요합니다.');
          return;
        }
      } else {
        var storagePermission = await Permission.storage.request();
        if (!storagePermission.isGranted) {
          _showErrorDialog('저장소 권한이 필요합니다.');
          return;
        }
      }

      // 이미지 다운로드 및 저장
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = imagePath.split('/').last;
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // 갤러리에 저장
        final result = await GallerySaver.saveImage(file.path);
        if (result != null && result) {
          _showErrorDialog('그림이 성공적으로 갤러리에 저장되었습니다!');
        } else {
          _showErrorDialog('이미지를 갤러리에 저장할 수 없습니다.');
        }
      } else {
        _showErrorDialog('이미지를 다운로드할 수 없습니다.');
      }
    } catch (e) {
      _showErrorDialog('이미지 저장 중 오류가 발생했습니다.');
      print('Error: $e');
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    final version = await _getAndroidVersion();
    return version >= 33;
  }

  Future<int> _getAndroidVersion() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      print('Failed to get Android version: $e');
      return 0; // 기본값으로 0 반환
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
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

  void _showDeleteConfirmationDialog(
      BuildContext context, DiaryModel diaryData) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete message",
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "정말 삭제하시겠어요??",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey)),
              child: Text(
                "아니요",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.04,
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
              child: Text(
                "네",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                try {
                  await ApiDiaryService.deleteDiary(diaryData.id.toString());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Footer(
                        selectedIndex: 3, // 일기 페이지로 돌아가도록 footer index 3 지정
                      ),
                    ),
                  );
                } catch (e) {
                  print('Failed to delete diary: $e');
                }
              },
            ),
          ],
        );
      },
    );
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Footer(
                                    selectedIndex:
                                        3, // 일기 페이지로 돌아가도록 footer index 3 지정
                                  )),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    FutureBuilder(
                      future: diary,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            formatDate(snapshot.data!.date),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.06,
                            ),
                          );
                        }
                        return Text(
                          '2024년 08월 00일',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.06,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      width: screenWidth * 0.07,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              FutureBuilder<DiaryModel>(
                future: diary,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 로딩 중일 때 SpinKitFadingCube 표시
                    return Center(
                      child: SpinKitFadingCube(
                        color: themeColor,
                        size: screenWidth * 0.1, // 사이즈 조절
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final diaryData = snapshot.data!;
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xEEEDEDED),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            border: Border.all(
                              color: themeColor, // 테두리 색상
                              width: 1, // 테두리 두께
                            ),
                          ),
                          width: double.infinity,
                          height: screenHeight * 0.35,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ), // 동일한 BorderRadius 적용
                            child: AspectRatio(
                              aspectRatio: 1, // 정사각형 비율로 설정
                              child: Image.network(
                                'https://i11b107.p.ssafy.io/api/serve/image?path=${diaryData.artImagePath}',
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // 이미지 로딩 완료
                                  } else {
                                    return Center(
                                      child: SpinKitFadingCube(
                                        color: themeColor,
                                        size: screenWidth * 0.1, // 사이즈 조절
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: themeColor,
                                width: 1,
                              ),
                              right: BorderSide(
                                color: themeColor,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: themeColor,
                                width: 1,
                              ),
                            ),
                          ),
                          width: double.infinity,
                          height: screenHeight * 0.45,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.02), // 왼쪽에 여백 추가
                                    child: Text(
                                      diaryData.title,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.065,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // 그림 저장 안내창
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Download message',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.07,
                                                  ),
                                                ),
                                                content: Text(
                                                  '그림을 저장하시겠어요??',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.05,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                Colors.grey)),
                                                    child: Text(
                                                      "아니요",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // 다이얼로그 닫기
                                                    },
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop(); // 다이얼로그 닫기
                                                      await _saveImageToDevice(
                                                          'https://i11b107.p.ssafy.io/api/serve/image?path=${diaryData.artImagePath}');
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                themeProvider
                                                                    .themeColor)),
                                                    child: Text(
                                                      '네',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.file_download_outlined,
                                          size: screenWidth * 0.07,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              context, diaryData);
                                        },
                                        icon: Icon(
                                          Icons.delete_forever_rounded,
                                          size: screenWidth * 0.07,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    diaryData.content,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "From. ${diaryData.name}",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.03,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DiaryUpdate(
                                            title: diaryData.title,
                                            context: diaryData.content,
                                            date: diaryData.date,
                                            diaryId: diaryData.id,
                                            artImagePath:
                                                diaryData.artImagePath,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      minimumSize: Size(screenWidth * 0.5,
                                          screenHeight * 0.06),
                                    ).copyWith(
                                      side: WidgetStatePropertyAll(
                                        BorderSide(
                                          color: themeColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '수정하기',
                                      style: TextStyle(
                                        color: themeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('일기를 불러올 수 없습니다.'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
