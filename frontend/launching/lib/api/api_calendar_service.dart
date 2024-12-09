import 'dart:convert';
import 'dart:io';
import 'package:daylog_launching/api/api_user_service.dart';
import 'package:daylog_launching/models/calendar/calendar_model.dart';
import 'package:http/http.dart' as http;

class ApiCalendarService {
  static const String baseUrl = "http://i11b107.p.ssafy.io:8080/api";

  // 해당 월 전체 일정 정보 가져오기
  static Future<List<ScheduleModel>> getSchedules(int year, int month) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    List<ScheduleModel> schedulesInstances = [];
    final response = await http.get(
      Uri.parse('$baseUrl/schedules/search?year=$year&month=$month'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> schedules =
          jsonDecode(utf8.decode(response.bodyBytes));
      for (var schedule in schedules) {
        schedulesInstances.add(ScheduleModel.fromJson(schedule));
      }
      return schedulesInstances;
    } else {
      throw HttpException(
          'Failed to load schedules. Status code: ${response.statusCode}');
    }
  }

  // 단일 일정 정보 가져오기
  static Future<ScheduleModel> getScheduleById(String id) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.get(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final schedule = jsonDecode(utf8.decode(response.bodyBytes));
      return ScheduleModel.fromJson(schedule);
    } else {
      throw HttpException(
          'Failed to load schedule. Status code: ${response.statusCode}');
    }
  }

  // 일정 삭제하기
  static Future<void> deleteSchedule(String id) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.delete(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to delete schedule. Status code: ${response.statusCode}');
    }
  }

  // 일정 수정하기
  static Future<void> updateSchedule(
      String id, Map<String, dynamic> updatedFields) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.patch(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
      body: jsonEncode(updatedFields),
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to update schedule. Status code: ${response.statusCode}');
    }
  }

  // 일정 생성하기
  static Future<void> saveDiary(String type, String content, String date,
      int startTime, int endTime, bool isMine) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
      body: jsonEncode(
        {
          "type": type,
          "date": date,
          "content": content,
          "startTime": startTime,
          "endTime": endTime,
          "isMine": isMine,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to save schedule. Status code: ${response.statusCode}');
    }
  }
}
