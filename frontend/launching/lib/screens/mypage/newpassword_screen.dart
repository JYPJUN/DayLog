import 'package:daylog_launching/api/api_user_service.dart';
import 'package:flutter/material.dart';
import '../mypage/mypage_screen.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

// 비밀번호 변경 페이지
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 비밀번호 업데이트
  void _updatePassword(BuildContext context) async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, '새 비밀번호가 일치하지 않습니다.');
      return;
    }

    final newPassword = _newPasswordController.text;
    final newPasswordCheck = await ApiUserService.updatePassword(newPassword);

    if (!mounted) return;

    if (newPasswordCheck) {
      _showSuccessDialog(context, '비밀번호가 성공적으로 변경되었습니다.');
      // 다이얼로그가 닫힌 후에 Navigator.push를 호출
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MypageScreen()),
        );
      });
    } else {
      _showErrorDialog(context, '비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('성공'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    late Color themeColor;
    late Color backColor;

    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        title: const Text(
          '새 비밀번호 설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: themeColor))),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: '새 비밀번호 확인',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: themeColor))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updatePassword(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: themeColor,
                minimumSize: const Size(400, 50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('비밀번호 변경'),
            ),
          ],
        ),
      ),
    );
  }
}
