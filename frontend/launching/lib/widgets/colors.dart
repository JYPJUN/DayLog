import 'package:flutter/material.dart';

const PRIMARY_COLOR = Color(0xffffabab);
final LIGHT_GREY_COLOR = Colors.grey[200]!;
final DARK_GREY_COLOR = Colors.grey[600]!;
final TEXT_FIELD_FILL_COLOR = Colors.grey[300]!;

const PRIMARY_COLOR_DARK = Color(0xff000000);
final LIGHT_GREY_COLOR_DARK = Colors.grey[800]!;
final DARK_GREY_COLOR_DARK = Colors.grey[900]!;
final TEXT_FIELD_FILL_COLOR_DARK = Colors.grey[700]!;

final ThemeData lightTheme = ThemeData(
  primaryColor: PRIMARY_COLOR,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: DARK_GREY_COLOR),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: TEXT_FIELD_FILL_COLOR,
    filled: true,
  ),
);

final ThemeData darkTheme = ThemeData(
  primaryColor: PRIMARY_COLOR_DARK,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: DARK_GREY_COLOR_DARK),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: TEXT_FIELD_FILL_COLOR_DARK,
    filled: true,
  ),
);
