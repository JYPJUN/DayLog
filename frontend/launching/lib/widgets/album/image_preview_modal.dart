import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:daylog_launching/api/api_album_service.dart';

class ImagePreviewModal extends StatelessWidget {
  final String imageUrl;
  final int mediaFileId;

  const ImagePreviewModal({
    super.key,
    required this.imageUrl,
    required this.mediaFileId,
  });

  Future<void> _deleteAlbum(BuildContext context) async {
    try {
      await ApiAlbumService.deleteAlbumByMediaFileId(mediaFileId);
      Navigator.of(context).pop(true); // 삭제가 완료되면 모달을 닫고 상위에 true 반환
    } catch (e) {
      print('Failed to delete album: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제에 실패했습니다. 다시 시도해 주세요.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 테마 색상 가져오기
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final themeColor = themeProvider.themeColor;

    return Scaffold(
      backgroundColor: Colors.black, // 전체 배경을 검정색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar 배경색을 검정색으로 설정
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: screenWidth * 0.08, // 아이콘 크기 설정
          ),
          onPressed: () => Navigator.of(context).pop(), // 뒤로 가기 동작 설정
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_forever_rounded,
              color: Colors.white,
              size: screenWidth * 0.08, // 삭제 아이콘 크기 설정
            ),
            onPressed: () async {
              // 삭제 확인 다이얼로그 표시
              final confirmDelete = await showDialog<bool>(
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
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.grey)),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                themeProvider.themeColor)),
                        onPressed: () => Navigator.of(context).pop(true),
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
                  );
                },
              );

              if (confirmDelete == true) {
                await _deleteAlbum(context);
              }
            },
          ),
        ],
        elevation: 0, // AppBar의 그림자 제거
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
