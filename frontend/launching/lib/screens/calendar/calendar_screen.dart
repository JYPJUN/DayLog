import 'package:daylog_launching/api/api_calendar_service.dart';
import 'package:daylog_launching/api/api_album_service.dart';
import 'package:daylog_launching/api/api_clip_service.dart';
import 'package:daylog_launching/models/album/album_model.dart';
import 'package:daylog_launching/models/calendar/calendar_model.dart';
import 'package:daylog_launching/models/clip/clip_model.dart';
import 'package:daylog_launching/widgets/album/attachment_bottom_sheet.dart';
import 'package:daylog_launching/widgets/album/image_preview_modal.dart';
import 'package:daylog_launching/widgets/album/video_player_modal.dart';
import 'package:daylog_launching/widgets/calendar/schedule_bottom_sheet.dart';
import 'package:daylog_launching/widgets/calendar/schedule_detail_modal.dart';
import 'package:daylog_launching/widgets/colors.dart';
import 'package:daylog_launching/widgets/calendar/main_calendar_widget.dart';
import 'package:daylog_launching/widgets/calendar/schedule_card_widget.dart';
import 'package:daylog_launching/widgets/calendar/today_banner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // speedDial
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDate = DateTime.now();
  Map<DateTime, List<ScheduleModel>> schedules = {};
  List<ScheduleModel> selectedSchedules = [];

  Map<DateTime, List<AlbumModel>> albums = {}; // 날짜별 앨범 정보를 저장할 맵 추가
  List<AlbumModel> selectedAlbums = []; // 선택된 날짜의 앨범 목록

  Map<DateTime, List<ClipModel>> clips = {}; // 날짜별 하이라이트 정보를 저장할 맵 추가
  List<ClipModel> selectedClips = []; // 선택된 날짜의 하이라이트 목록

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSchedules(focusedDate);
    _fetchAlbums(focusedDate);
    _fetchClips(focusedDate);
  }

  Future<void> _fetchAlbums(DateTime date) async {
    try {
      List<AlbumModel> fetchedAlbums = await ApiAlbumService.getAlbums(
        date.year,
        date.month,
      );

      setState(() {
        albums = _groupAlbumsByDate(fetchedAlbums);
        selectedAlbums = albums[selectedDate] ?? [];
      });
    } catch (e) {
      print('Failed to load albums: $e');
    }
  }

  Future<void> _fetchClips(DateTime date) async {
    try {
      List<ClipModel> fetchedClips = await ApiClipService.getClips(
        date.year,
        date.month,
      );

      setState(() {
        clips = _groupClipsByDate(fetchedClips);
        selectedClips = clips[selectedDate] ?? [];
      });
    } catch (e) {
      print('Failed to load clips: $e');
    }
  }

  Map<DateTime, List<AlbumModel>> _groupAlbumsByDate(List<AlbumModel> albums) {
    Map<DateTime, List<AlbumModel>> data = {};
    for (var album in albums) {
      // 문자열을 DateTime으로 변환
      DateTime date = DateTime.parse(album.date.replaceAll(' ', 'T'));
      // 날짜 부분만 추출 (UTC로 변환하여 비교)
      DateTime dateOnly = DateTime.utc(date.year, date.month, date.day);
      if (data[dateOnly] == null) data[dateOnly] = [];
      data[dateOnly]!.add(album);
    }
    return data;
  }

  Map<DateTime, List<ClipModel>> _groupClipsByDate(List<ClipModel> clips) {
    Map<DateTime, List<ClipModel>> data = {};
    for (var clip in clips) {
      // 문자열을 DateTime으로 변환
      DateTime date = DateTime.parse(clip.date.replaceAll(' ', 'T'));
      // 날짜 부분만 추출 (UTC로 변환하여 비교)
      DateTime dateOnly = DateTime.utc(date.year, date.month, date.day);
      if (data[dateOnly] == null) data[dateOnly] = [];
      data[dateOnly]!.add(clip);
    }
    return data;
  }

  Future<void> _fetchSchedules(DateTime date) async {
    try {
      List<ScheduleModel> fetchedSchedules =
          await ApiCalendarService.getSchedules(
        date.year,
        date.month,
      );
      setState(() {
        schedules = _groupSchedulesByDate(fetchedSchedules);
        selectedSchedules = schedules[selectedDate] ?? [];
      });
    } catch (e) {
      print(e);
    }
  }

  Map<DateTime, List<ScheduleModel>> _groupSchedulesByDate(
      List<ScheduleModel> schedules) {
    Map<DateTime, List<ScheduleModel>> data = {};
    for (var schedule in schedules) {
      // 문자열을 DateTime으로 변환
      DateTime date = DateTime.parse(schedule.date.replaceAll(' ', 'T'));
      // 날짜 부분만 추출 (UTC로 변환하여 비교)
      DateTime dateOnly = DateTime.utc(date.year, date.month, date.day);
      if (data[dateOnly] == null) data[dateOnly] = [];
      data[dateOnly]!.add(schedule);
    }
    return data;
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // selectedDate도 UTC로 변환하여 비교
      selectedDate =
          DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
      focusedDate =
          DateTime.utc(focusedDay.year, focusedDay.month, focusedDay.day);
      selectedSchedules = schedules[selectedDate] ?? [];
      selectedAlbums = albums[selectedDate] ?? [];
      selectedClips = clips[selectedDate] ?? [];
    });

    // 스크롤 위치를 처음으로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // 새로운 달로 이동할 때 호출
  void onMonthChanged(DateTime newFocusedDate) {
    setState(() {
      focusedDate = newFocusedDate;
    });
    _fetchSchedules(focusedDate);
    _fetchAlbums(focusedDate);
    _fetchClips(focusedDate);
  }

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
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      floatingActionButton: SpeedDial(
        backgroundColor: themeColor,
        foregroundColor: Colors.white, // 아이콘의 색상을 변경
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.white,
        overlayOpacity: 0.3,
        spacing: 8,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            backgroundColor: themeColor,
            labelBackgroundColor: themeColor,
            child: const Icon(
              Icons.edit_calendar_outlined,
              color: Colors.white,
            ),
            label: '일정 추가', // 필요에 따라 label을 추가하세요
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isDismissible: true, // 배경을 탭했을 때 BottomSheet 닫기
                builder: (_) => ScheduleBottomSheet(
                  selectedDate: selectedDate,
                ),
                isScrollControlled: true,
              );

              // 저장이 성공적으로 완료되었을 때 일정 갱신
              if (result == true) {
                _fetchSchedules(focusedDate); // 일정 데이터 갱신
              }
            },
          ),
          SpeedDialChild(
            backgroundColor: themeColor,
            labelBackgroundColor: themeColor,
            child: const Icon(
              Icons.file_present,
              color: Colors.white,
            ),
            label: '파일 첨부', // 필요에 따라 label을 추가하세요
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isDismissible: true, // 배경을 탭했을 때 BottomSheet 닫기
                builder: (_) => AttachmentBottomSheet(
                  selectedDate: selectedDate,
                ),
                isScrollControlled: true,
              );

              // 저장이 성공적으로 완료되었을 때 일정 갱신
              if (result == true) {
                _fetchAlbums(focusedDate); // 파일 첨부 후 앨범 데이터 갱신
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.05, // 위쪽 패딩
          bottom: screenHeight * 0.02, // 아래쪽 패딩
          left: screenWidth * 0.05, // 왼쪽 패딩
          right: screenWidth * 0.05, // 오른쪽 패딩
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MainCalendar(
                selectedDate: selectedDate,
                onDaySelected: onDaySelected,
                eventLoader: schedules,
                onPageChanged: onMonthChanged, // 달력이 새로운 달로 이동할 때 호출
                albumLoader: albums, // 앨범 데이터를 로드하는 함수 추가
                clipLoader: clips,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              TodayBanner(
                selectedDate: selectedDate,
                count: selectedSchedules.length, // 일정 개수
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                height: screenHeight * 0.1, // 카드 높이를 명시적으로 설정
                child: selectedSchedules.isEmpty
                    ? Center(
                        child: Text(
                          "이 날은 일정이 없어요",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = selectedSchedules[index];
                          // 스케줄이 1개일 경우와 그 외의 경우에 따른 width 설정
                          final cardWidth =
                              selectedSchedules.length == 1 ? 0.9 : 0.7;
                          final cardPadding =
                              selectedSchedules.length == 1 ? 0 : 0.03;

                          return Padding(
                            padding: EdgeInsets.only(
                                right: screenWidth * cardPadding), // 카드 간의 간격
                            child: GestureDetector(
                              onTap: () async {
                                // 일정 클릭 시 모달 창을 띄웁니다.
                                final result2 =
                                    await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.0),
                                    ),
                                  ),
                                  builder: (_) => Scheduledetailmodal(
                                    id: schedule.id,
                                    startTime: schedule.startTime,
                                    endTime: schedule.endTime,
                                    content: schedule.content,
                                    type: schedule.type,
                                    isMine: schedule.isMine,
                                    date: schedule.date,
                                  ),
                                );

                                // 저장이 성공적으로 완료되었을 때 일정 갱신
                                if (result2 == true) {
                                  _fetchSchedules(focusedDate); // 일정 데이터 갱신
                                }
                              },
                              child: ScheduleCard(
                                startTime: schedule.startTime,
                                endTime: schedule.endTime,
                                content: schedule.content,
                                width: cardWidth, // 조건에 따른 가로 길이 전달
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                children: [
                  Icon(
                    Icons.video_collection_rounded,
                    color: DARK_GREY_COLOR,
                  ),
                  SizedBox(
                    width: screenHeight * 0.01,
                  ),
                  Text(
                    '하이라이트',
                    style: TextStyle(
                      color: DARK_GREY_COLOR,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: screenHeight * 0.12, // ListView의 높이를 명시적으로 설정
                child: selectedClips.isEmpty
                    ? Center(
                        child: Text(
                          "하이라이트가 없어요",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedClips.length,
                        itemBuilder: (context, index) {
                          final clip = selectedClips[index];
                          return FutureBuilder<File>(
                            future: getThumbnail(clip.filePath),
                            builder: (context, snapshot) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01,
                                ),
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.1,
                                child: snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? SpinKitFadingCube(
                                        color: themeColor,
                                        size: screenWidth * 0.05, // 사이즈 조절
                                      )
                                    : snapshot.hasError
                                        ? const Icon(Icons.error,
                                            color: Colors.red)
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VideoPlayerModal(
                                                    videoUrl:
                                                        'https://i11b107.p.ssafy.io/api/serve/image?path=${clip.filePath}',
                                                    mediaFileId: clip.id,
                                                    isClip: true,
                                                  ),
                                                ),
                                              ).then((result) {
                                                // 모달이 닫힌 후의 작업 처리
                                                if (result == true) {
                                                  // 삭제가 성공적으로 완료된 후의 새로고침 작업
                                                  _fetchClips(focusedDate);
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xEEEDEDED),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image: DecorationImage(
                                                  image: FileImage(snapshot
                                                      .data!), // 비디오의 썸네일 이미지 사용
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                children: [
                  Icon(
                    Icons.attachment_rounded,
                    color: DARK_GREY_COLOR,
                  ),
                  SizedBox(
                    width: screenHeight * 0.01,
                  ),
                  Text(
                    '첨부 파일',
                    style: TextStyle(
                      color: DARK_GREY_COLOR,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: screenHeight * 0.12, // ListView의 높이 설정
                child: selectedAlbums.isEmpty
                    ? Center(
                        child: Text(
                          "첨부된 파일이 없어요",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedAlbums.length,
                        itemBuilder: (context, index) {
                          final album = selectedAlbums[index];
                          return FutureBuilder<File>(
                            future: getThumbnail(album.filePath),
                            builder: (context, snapshot) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01,
                                ),
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.1,
                                child: snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? SpinKitFadingCube(
                                        color: themeColor,
                                        size: screenWidth * 0.05, // 사이즈 조절
                                      )
                                    : snapshot.hasError
                                        ? const Icon(Icons.error,
                                            color: Colors.red)
                                        : GestureDetector(
                                            onTap: () {
                                              if (album.filePath
                                                      .endsWith('.jpg') ||
                                                  album.filePath
                                                      .endsWith('.jpeg') ||
                                                  album.filePath
                                                      .endsWith('.png')) {
                                                // 이미지 모달 띄우기
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImagePreviewModal(
                                                      imageUrl:
                                                          'https://i11b107.p.ssafy.io/api/serve/image?path=${album.filePath}',
                                                      mediaFileId: album.id,
                                                    ),
                                                  ),
                                                ).then((result) {
                                                  // 모달이 닫힌 후의 작업 처리
                                                  if (result == true) {
                                                    // 삭제가 성공적으로 완료된 후의 새로고침 작업
                                                    _fetchAlbums(focusedDate);
                                                  }
                                                });
                                              } else if (album.filePath
                                                  .endsWith('.mp4')) {
                                                // 비디오 모달 띄우기
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VideoPlayerModal(
                                                      videoUrl:
                                                          'https://i11b107.p.ssafy.io/api/serve/image?path=${album.filePath}',
                                                      mediaFileId: album.id,
                                                    ),
                                                  ),
                                                ).then((result) {
                                                  // 모달이 닫힌 후의 작업 처리
                                                  if (result == true) {
                                                    // 삭제가 성공적으로 완료된 후의 새로고침 작업
                                                    _fetchAlbums(focusedDate);
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xEEEDEDED),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image: DecorationImage(
                                                  image: album.filePath
                                                          .endsWith('.mp4')
                                                      ? FileImage(snapshot
                                                          .data!) // 비디오의 썸네일 이미지 사용
                                                      : NetworkImage(
                                                          'https://i11b107.p.ssafy.io/api/serve/image?path=${album.filePath}',
                                                        ) as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File> getThumbnail(String filePath) async {
    final isImage = filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.png');
    final isVideo = filePath.endsWith('.mp4') ||
        filePath.endsWith('.avi') ||
        filePath.endsWith('.mov');

    if (isImage) {
      // 이미지의 경우, 이미지를 바로 사용
      return File(filePath);
    } else if (isVideo) {
      // 비디오의 경우, 썸네일 생성
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: 'https://i11b107.p.ssafy.io/api/serve/image?path=$filePath',
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );

      return File(thumbnail!);
    }

    throw Exception('Unsupported file type');
  }
}
