import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class ProfileImage extends StatelessWidget {
  final File? image;
  final String profileImage;
  final VoidCallback onTap;

  const ProfileImage({
    super.key,
    required this.image,
    required this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeColor = themeProvider.themeColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.2), // 그림자 색상 테마 컬러로 설정
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3), // 그림자의 위치 (x, y)
            ),
          ],
        ),
        child: ClipOval(
          child: image == null
              ? Image.network(
                  'https://i11b107.p.ssafy.io/api/serve/image?path=$profileImage',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: SpinKitFadingCube(
                            color: themeColor, // 로딩 스피너 색상 테마 컬러로 설정
                            size: 50.0,
                          ),
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Icon(
                          Icons.error,
                          color: themeColor, // 에러 아이콘 색상 테마 컬러로 설정
                          size: 50.0,
                        ),
                      ),
                    );
                  },
                )
              : Image.file(
                  image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
