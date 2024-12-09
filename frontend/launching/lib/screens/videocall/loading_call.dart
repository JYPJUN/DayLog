import 'package:daylog_launching/screens/videocall/prepare_videocall.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class LoadingCall extends StatefulWidget {
  const LoadingCall({super.key});

  @override
  State<LoadingCall> createState() => _LoadingCallState();
}

class _LoadingCallState extends State<LoadingCall> {
  Future<void> _checkPermissionsAndMakeCall() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];

    try {
      // 필요한 모든 권한 요청
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      // 모든 권한이 부여되었는지 확인
      bool allPermissionsGranted =
          statuses.values.every((status) => status.isGranted);

      if (allPermissionsGranted) {
        // 모든 권한이 부여된 경우
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PrepareVideocall()));
        }
      } else {
        // 권한이 거부되었거나 영구적으로 거부된 경우
        if (mounted) {
          _showPermissionDeniedMessage(statuses);
        }
      }
    } catch (e) {
      if (mounted) {
        _showPermissionDeniedMessage({});
      }
    }
  }

  void _showPermissionDeniedMessage(
      Map<Permission, PermissionStatus> statuses) {
    bool permanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(permanentlyDenied
            ? '설정에서 권한을 허용해주세요.'
            : '모든 권한이 필요합니다. 다시 시도해주세요.'),
        action: SnackBarAction(
          label: '다시 시도',
          onPressed: permanentlyDenied
              ? () => openAppSettings()
              : _checkPermissionsAndMakeCall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color themeColor = themeProvider.themeColor;
    final String videoBackImage = themeProvider.videoback;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            videoBackImage, // 동적으로 배경 이미지 설정
            fit: BoxFit.cover,
          ),
          Lottie.asset(
            'assets/anime/waitcat1.json',
            fit: BoxFit.cover, // 화면 전체를 덮도록 설정
          ),
          Center(
            child: SizedBox(
              width: 90.0, // 원하는 너비 설정
              height: 90.0, // 원하는 높이 설정
              child: FloatingActionButton(
                onPressed: _checkPermissionsAndMakeCall,
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 8.0,
                child: const Icon(Icons.call,
                    color: Colors.white, size: 40.0), // 아이콘 크기 조정
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose 메서드에서 필요한 정리 작업을 수행합니다.
    super.dispose();
  }
}
