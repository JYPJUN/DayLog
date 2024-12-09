import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String themeColorKey = 'themeColor';
  static const String bgColorKey = 'bgColor';
  static const String selectedThemeKey = 'selectedTheme';
  static const String videoBackImageKey = 'videobackImage';

  Color _themeColor = const Color(0xFFff9292);
  Color _backColor = const Color(0xFFFFFFFF);
  String _selectedTheme = 'default';
  String _videobackImage = 'assets/imgs/videocall.png';

  Color get themeColor => _themeColor;
  Color get backColor => _backColor;
  String get selectedTheme => _selectedTheme;
  String get videoback => _videobackImage;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(themeColorKey) ?? '0xFFff9292';
    final bgColorValue = prefs.getString(bgColorKey) ?? '0xFFFFFFFF';
    _themeColor =
        Color(int.parse(themeValue.replaceFirst('0x', ''), radix: 16));
    _backColor =
        Color(int.parse(bgColorValue.replaceFirst('0x', ''), radix: 16));
    _selectedTheme = prefs.getString(selectedThemeKey) ?? 'default';
    _videobackImage =
        prefs.getString(videoBackImageKey) ?? 'assets/imgs/videocall.png';
    notifyListeners();
  }

  Future<void> setTheme(String themeKey, Color color, Color bgColor) async {
    final prefs = await SharedPreferences.getInstance();

    // 선택된 테마에 따른 이미지 설정
    String newVideoBackImage;
    switch (themeKey) {
      case 'theme1':
        newVideoBackImage = 'assets/imgs/videocall_purple_2.jpg';
        break;
      case 'theme2':
        newVideoBackImage = 'assets/imgs/videocall_pink.jpg';
        break;
      case 'theme3':
        newVideoBackImage = 'assets/imgs/videocall_blue.jpg';
        break;
      default:
        newVideoBackImage = 'assets/imgs/videocall.png';
        break;
    }

    await prefs.setString(
        themeColorKey, '0x${color.value.toRadixString(16).padLeft(8, '0')}');
    await prefs.setString(
        bgColorKey, '0x${bgColor.value.toRadixString(16).padLeft(8, '0')}');
    await prefs.setString(selectedThemeKey, themeKey);
    await prefs.setString(videoBackImageKey, newVideoBackImage);

    _themeColor = color;
    _backColor = bgColor;
    _selectedTheme = themeKey;
    _videobackImage = newVideoBackImage;

    notifyListeners();
  }
}
