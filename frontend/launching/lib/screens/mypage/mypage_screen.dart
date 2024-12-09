import 'package:daylog_launching/api/api_user_service.dart';
import 'package:daylog_launching/providers/alarm_provider.dart';
import 'package:daylog_launching/screens/mypage/changepassword_screen.dart';
import 'package:daylog_launching/screens/mypage/notification_screen.dart';
import 'package:daylog_launching/screens/mypage/notify_screen.dart';
import 'package:daylog_launching/screens/mypage/theme_setting_screen.dart';
import 'package:daylog_launching/widgets/setting/menu_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2), // 그림자의 위치 (x, y)
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

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _newNicknameController = TextEditingController();
  String nickname = ''; // 닉네임 초기화
  String profileImage = ''; // 이미지 경로 초기화
  File? image;
  final TextEditingController _passwordController = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    Provider.of<AlaramState>(context, listen: false).fetchAlarmCount();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _newNicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await ApiUserService.userInfo();
    setState(() {
      nickname = utf8.decode(userInfo['name'].runes.toList());
      profileImage = userInfo['profileImagePath'];
    });
  }

  Future<void> changeNickname() async {
    _newNicknameController.text = _nicknameController.text;
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('아이디 변경'),
        content: SingleChildScrollView(
          child: TextField(
            controller: _newNicknameController,
            decoration: const InputDecoration(
              hintText: '새 닉네임 입력',
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final newNickname = _newNicknameController.text;
              Navigator.pop(context);
              setState(() {
                nickname = newNickname;
              });
              ApiUserService.updateNickname(nickname);
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  Future<void> changeProfileImage() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('사진 찍기'),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        image = File(pickedFile.path);
                      });
                      await ApiUserService.updateProfileImage(image!);
                      await _loadUserInfo();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('앨범 선택'),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        image = File(pickedFile.path);
                      });
                      await ApiUserService.updateProfileImage(image!);
                      await _loadUserInfo();
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("오류 발생: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  void _showPasswordDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      useSafeArea: true, // 키보드가 올라올 때 픽셀 오류를 방지합니다.
      builder: (BuildContext context) => AlertDialog(
        title: const Text('비밀번호 확인'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('계정을 삭제하려면 비밀번호를 입력해주세요.'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final alarmCount = Provider.of<AlaramState>(context).alarmCount;

    return Scaffold(
      backgroundColor: themeProvider.backColor,
      appBar: AppBar(
        title: const Text(
          'My Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.themeColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileImage(
              image: image,
              profileImage: profileImage,
              onTap: changeProfileImage,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: changeNickname,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nickname,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.themeColor, // 테마 색상으로 설정
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.edit,
                    size: 24,
                    color: themeProvider.themeColor, // 테마 색상으로 설정
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                children: [
                  MenuButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifyScreen(),
                        ),
                      );
                    },
                    icon: Icons.chat_bubble_outlined,
                    label: '공지사항',
                    themeColor: themeProvider.themeColor,
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: MenuButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                            // 알람 화면을 본 후 알람 수 갱신
                            Provider.of<AlaramState>(context, listen: false)
                                .fetchAlarmCount();
                          },
                          icon: Icons.notifications_active_rounded,
                          label: '알림',
                          themeColor: themeProvider.themeColor,
                        ),
                      ),
                      if (alarmCount > 0)
                        Positioned(
                          right: 20,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$alarmCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  MenuButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingScreen(),
                        ),
                      );
                    },
                    icon: Icons.color_lens_rounded,
                    label: '테마',
                    themeColor: themeProvider.themeColor,
                  ),
                  MenuButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangepasswordScreen(),
                        ),
                      );
                    },
                    icon: Icons.password_outlined,
                    label: '비밀번호\n변경',
                    themeColor: themeProvider.themeColor,
                  ),
                  MenuButton(
                    onPressed: () {
                      if (!mounted) return;
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('아니오'),
                            ),
                            TextButton(
                              onPressed: () {
                                ApiUserService.logOut();
                                Navigator.pop(context);
                                _signOut(); // 로그아웃 메서드 호출
                              },
                              child: const Text('예'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icons.logout_rounded,
                    label: '로그아웃',
                    themeColor: themeProvider.themeColor,
                  ),
                  MenuButton(
                    onPressed: _showPasswordDialog,
                    icon: Icons.supervised_user_circle_rounded,
                    label: '회원 탈퇴',
                    themeColor: themeProvider.themeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
