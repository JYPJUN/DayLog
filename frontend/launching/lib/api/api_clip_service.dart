import 'dart:convert';
import 'dart:io';
import 'package:daylog_launching/api/api_user_service.dart';
import 'package:daylog_launching/models/clip/clip_model.dart';
import 'package:http/http.dart' as http;

class ApiClipService {
  static const String baseUrl = "http://i11b107.p.ssafy.io:8080/api";

  // 핫클립 조회
  static Future<List<ClipModel>> getClips(int year, int month) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    List<ClipModel> clipsInstances = [];
    final response = await http.get(
      Uri.parse('$baseUrl/clips?year=$year&month=$month'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> clips = jsonDecode(utf8.decode(response.bodyBytes));
      for (var clip in clips) {
        clipsInstances.add(ClipModel.fromJson(clip));
      }
      return clipsInstances;
    } else {
      throw HttpException(
          'Failed to load schedule. Status code: ${response.statusCode}');
    }
  }

  // 핫클립 삭제
  static Future<void> deleteClipById(int id) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.delete(
      Uri.parse('$baseUrl/clips/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to delete clip. Status code: ${response.statusCode}');
    }
  }
}
