import 'package:flutter/material.dart';

class DiaryViewProvider with ChangeNotifier {
  bool _showOnlyImages = false;

  bool get showOnlyImages => _showOnlyImages;

  void toggleView(bool value) {
    _showOnlyImages = value;
    notifyListeners();
  }
}
