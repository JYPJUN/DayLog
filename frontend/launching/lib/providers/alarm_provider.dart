import 'package:daylog_launching/api/api_user_service.dart';
import 'package:flutter/material.dart';

class AlaramState extends ChangeNotifier {
  int _alarmCount = 0; // 초기 값을 0으로 설정

  int get alarmCount => _alarmCount;

  // API로부터 알람 카운트를 갱신하는 메서드
  Future<void> fetchAlarmCount() async {
    _alarmCount = await ApiUserService.alarmCount();
    print('#######################');
    print(_alarmCount);
    notifyListeners();
  }

  // 알람 카운트를 강제로 업데이트하는 메서드
  Future<void> updateAlarmCount() async {
    await fetchAlarmCount(); // 최신 카운트를 API에서 가져옴
  }

  // 알람 카운트를 리셋하는 메서드
  Future<void> resetAlarmCount() async {
    await fetchAlarmCount(); // 최신 카운트를 API에서 가져옴
  }
}
