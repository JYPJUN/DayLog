import 'package:daylog_launching/api/api_diary_service.dart';
import 'package:daylog_launching/models/diary/diary_model.dart';
import 'package:daylog_launching/screens/diary/diary_add.dart';
import 'package:daylog_launching/screens/diary/diary_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:daylog_launching/providers/diary_view_provider.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // bool showOnlyImages = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 변수명 설정
    late Color themeColor;
    late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    final diaryViewProvider = Provider.of<DiaryViewProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                Expanded(
                  child: Text(
                    '그림 일기',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: diaryViewProvider.showOnlyImages
                            ? themeColor
                            : Colors.grey,
                        size: screenWidth * 0.08,
                      ),
                      onPressed: () {
                        diaryViewProvider.toggleView(true);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.format_list_bulleted_rounded,
                        color: !diaryViewProvider.showOnlyImages
                            ? themeColor
                            : Colors.grey,
                        size: screenWidth * 0.08,
                      ),
                      onPressed: () {
                        diaryViewProvider.toggleView(false);
                      },
                    ),
                    SizedBox(
                      width: screenWidth * 0.01,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Expanded(
              child: FutureBuilder<List<DiaryModel>>(
                future: ApiDiaryService.getDiaries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // SpinKit 사용하여 로딩 인디케이터 표시
                    return Center(
                      child: SpinKitFadingCube(
                        color: themeColor,
                        size: screenWidth * 0.1, // 사이즈 조절
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print("Error: ${snapshot.error}"); // 디버깅용 로그
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print("Data: ${snapshot.data}"); // 디버깅용 로그
                    return Center(
                        child: Text(
                      '아직 작성한 일기가 없습니다 ㅠㅠ',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final diaries = snapshot.data!;
                    return !diaryViewProvider.showOnlyImages
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: screenHeight * 0.015,
                              crossAxisSpacing: screenWidth * 0.03,
                              childAspectRatio: 1,
                            ),
                            itemCount: diaries.length,
                            itemBuilder: (context, index) {
                              final diary = diaries[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiaryDetail(
                                        id: diary.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xEEEDEDED),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: themeColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        15), // 동일한 BorderRadius 적용
                                    child: Stack(
                                      children: [
                                        // 이미지를 로드하기 전에 표시될 인디케이터
                                        Positioned.fill(
                                          child: Image.network(
                                            'https://i11b107.p.ssafy.io/api/serve/image?path=${diary.artImagePath}',
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child; // 이미지를 다 불러왔으면 반환
                                              } else {
                                                return Center(
                                                  child: SpinKitFadingCube(
                                                    color: themeColor,
                                                    size: screenWidth *
                                                        0.1, // 사이즈 조절
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: diaries.length,
                            itemBuilder: (context, index) {
                              var diary = diaries[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01,
                                  horizontal: screenWidth * 0.03,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DiaryDetail(id: diary.id),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.03),
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                bottomLeft: Radius.circular(30),
                                              ),
                                            ),
                                            width: screenWidth * 0.5,
                                            height: screenHeight * 0.22,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  diary.title,
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.06,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  diary.date,
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.03,
                                                      color: Colors.grey),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      diary.content,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xEEEDEDED),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            width: screenWidth * 0.4,
                                            height: screenHeight * 0.2, // 높이 설정
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // 모서리를 둥글게 설정
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: Image.network(
                                                      'https://i11b107.p.ssafy.io/api/serve/image?path=${diary.artImagePath}',
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child; // 이미지를 다 불러왔으면 반환
                                                        } else {
                                                          return Center(
                                                            child:
                                                                SpinKitFadingCube(
                                                              color: themeColor,
                                                              size: screenWidth *
                                                                  0.1, // 사이즈 조절
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 0.5, // 두께를 지정
                                        indent: 10.0, // 왼쪽 여백을 20.0으로 설정
                                        endIndent: 10.0, // 오른쪽 여백을 20.0으로 설정
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: screenWidth * 0.85,
        height: screenHeight * 0.07,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DiaryAdd(),
              ),
            );
          },
          backgroundColor: themeColor,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '그림 일기 작성하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
