import 'package:daylog_launching/api/api_album_service.dart';
import 'package:daylog_launching/widgets/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/album/album_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AttachmentBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final AlbumModel? initialAlbum; // 초기 앨범 데이터를 받을 수 있도록 추가

  const AttachmentBottomSheet({
    super.key,
    required this.selectedDate,
    this.initialAlbum, // 초기 앨범 데이터
  });

  @override
  State<AttachmentBottomSheet> createState() => _AttachmentBottomSheetState();
}

class _AttachmentBottomSheetState extends State<AttachmentBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey(); // 폼키 생성
  List<File> attachments = []; // 첨부파일 리스트
  bool _isLoading = false; // 로딩 상태를 관리하는 변수

  @override
  void initState() {
    super.initState();

    // 초기 앨범 데이터가 있을 경우 이를 첨부파일 리스트에 추가
    if (widget.initialAlbum != null) {
      // 초기 앨범 데이터가 File 객체가 아닌 경우 수정 필요
      // attachments.add(File(widget.initialAlbum!.filePath));
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

    return Stack(
      children: [
        Form(
            key: formKey,
            child: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    )),
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
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Files:',
                        style: TextStyle(
                          color: DARK_GREY_COLOR,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: attachments.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: attachments.length,
                                itemBuilder: (context, index) {
                                  return Text(attachments[index].path);
                                },
                              )
                            : Text(
                                '첨부된 파일이 없습니다.',
                                style: TextStyle(color: DARK_GREY_COLOR),
                              ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      SizedBox(
                        width: screenWidth * 1,
                        height: screenWidth * 0.5,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _pickFiles, // 로딩 중일 때는 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xfff5f5f5), // 배경 색상 설정
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // 모서리를 둥글게 설정
                            ),
                          ),
                          child: Icon(
                            Icons.upload,
                            size: screenWidth * 0.12,
                            color: DARK_GREY_COLOR,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : onSavePressed, // 로딩 중일 때는 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                          ),
                          child: Text(
                            '제출하기',
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
            )),
        if (_isLoading) // 로딩 중일 때 인디케이터와 안내문을 화면에 표시
          Positioned.fill(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                    "파일을 업로드하는 중입니다.",
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

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // 이미지와 동영상을 모두 선택할 수 있는 메서드
  void _pickFiles() async {
    // 권한 요청
    await requestStoragePermission();

    // 파일 선택기 등을 사용하여 파일을 선택 후 리스트에 추가
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'avi', 'mov'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        attachments = result.paths
            .map((path) => File(path!))
            .where((file) => file.lengthSync() <= 50 * 1024 * 1024) // 50MB 제한
            .toList();
      });

      if (attachments.length != result.paths.length) {
        _showFileSizeExceededDialog();
      }
    }
  }

  void _showFileSizeExceededDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('파일 크기 제한 초과'),
          content:
              const Text('일부 파일이 크기 제한으로 인해 제외되었습니다. 50MB 이하의 파일만 첨부 가능합니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void onSavePressed() async {
    String formattedDate =
        '${widget.selectedDate.year.toString().padLeft(4, '0')}-'
        '${widget.selectedDate.month.toString().padLeft(2, '0')}-'
        '${widget.selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      await ApiAlbumService.saveAlbums(
        files: attachments, // 파일 리스트 전달
        date: formattedDate, // 선택한 날짜 전달
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Failed to save album: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }
}
