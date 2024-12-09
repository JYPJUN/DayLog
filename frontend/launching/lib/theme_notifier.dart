// import 'dart:async';

// class ThemeNotifier {
//   static final ThemeNotifier _instance = ThemeNotifier._internal();

//   factory ThemeNotifier() {
//     return _instance;
//   }

//   ThemeNotifier._internal();

//   final _themeStreamController = StreamController<void>.broadcast();

//   Stream<void> get stream => _themeStreamController.stream;

//   void notifyListeners() {
//     _themeStreamController.add(null);
//   }
// }
