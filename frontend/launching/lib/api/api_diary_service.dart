import 'dart:convert';
import 'dart:io';
import 'package:daylog_launching/api/api_user_service.dart';
import 'package:daylog_launching/models/diary/diary_model.dart';
import 'package:http/http.dart' as http;

class ApiDiaryService {
  static const String baseUrl = "http://i11b107.p.ssafy.io:8080/api";

  // 전체 그림 일기 정보 가져오기
  static Future<List<DiaryModel>> getDiaries() async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    List<DiaryModel> diaryInstances = [];
    final response = await http.get(
      Uri.parse('$baseUrl/diaries'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> diaries = jsonDecode(utf8.decode(response.bodyBytes));
      for (var diary in diaries) {
        diaryInstances.add(DiaryModel.fromJson(diary));
      }
      return diaryInstances;
    } else {
      throw HttpException(
          'Failed to load diaries. Status code: ${response.statusCode}');
    }
  }

  // 단일 그림 일기 정보 가져오기
  static Future<DiaryModel> getDiary(int id) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.get(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final diary = jsonDecode(utf8.decode(response.bodyBytes));
      return DiaryModel.fromJson(diary);
    } else {
      throw HttpException(
          'Failed to load diary. Status code: ${response.statusCode}');
    }
  }

  // 일기 삭제하기
  static Future<void> deleteDiary(String id) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.delete(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to delete diary. Status code: ${response.statusCode}');
    }
  }

  // 일기 수정하기
  static Future<void> updateDiary(int id, String title, String content,
      String artImagePath, String date) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.patch(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
      body: jsonEncode(
        {
          "title": title,
          "content": content,
          "artImagePath": artImagePath,
          "date": date,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to update diary. Status code: ${response.statusCode}');
    }
  }

  // 이미지 생성하기
  static Future<String> getImage(String content) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.get(
      Uri.parse('$baseUrl/diaries/generate-image?content=$content'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;

      // 응답 본문이 JSON 형식인지 확인
      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('imageUrl')) {
          return jsonResponse['imageUrl'];
        } else {
          throw const FormatException(
              'JSON 응답 본문에서 \'imageUrl\' 필드를 찾을 수 없습니다.');
        }
      } catch (e) {
        // JSON 디코딩 오류가 발생했을 때는 응답 본문이 직접 URL일 경우를 처리
        if (Uri.tryParse(responseBody)?.isAbsolute ?? false) {
          return responseBody; // 응답 본문이 URL로 보일 경우
        } else {
          throw FormatException('응답 본문 형식이 잘못되었습니다: $e');
        }
      }
    } else {
      throw HttpException('이미지 생성을 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 일기 작성하기
  static Future<void> saveDiary(
      String title, String content, String artImagePath, String date) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.post(
      Uri.parse('$baseUrl/diaries'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
      body: jsonEncode(
        {
          "title": title,
          "content": content,
          "artImagePath": artImagePath,
          "date": date,
        },
      ),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw HttpException(
          'Failed to save diary. Status code: ${response.statusCode}');
    }
  }
}
