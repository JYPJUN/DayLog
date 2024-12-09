import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const baseUrl = 'https://i11b107.p.ssafy.io/api';

Future<Color> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final themeValue = prefs.getString('themeColor') ?? '0xFFFFABAB';
  return Color(int.parse(themeValue.replaceFirst('0x', ''), radix: 16));
}
