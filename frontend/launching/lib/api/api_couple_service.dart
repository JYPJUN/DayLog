import 'package:daylog_launching/models/couple/couple_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/api_user_service.dart';

class ApiCoupleService {
  static const String baseUrl = 'https://i11b107.p.ssafy.io/api';

  // 커플 정보 API 호출
  static Future<CoupleInfo> getCoupleInfo() async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.get(
      Uri.parse('$baseUrl/couples'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return CoupleInfo.fromJson(responseBody);
    } else {
      throw Exception('커플 정보 조회 실패: ${response.statusCode}');
    }
  }

  static Future<void> updateRelationshipStartDate(
      DateTime relationshipStartDate) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    await http.patch(
        Uri.parse('$baseUrl/couples/update/relationship-start-date'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken"
        },
        body: jsonEncode({
          'relationshipStartDate': relationshipStartDate.toIso8601String()
        }));
  }

  // 커플 코드 POST 요청
  static Future<bool> coupleCode(String code) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.post(
      Uri.parse('$baseUrl/holds'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'coupleCode': code}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw false;
    }
  }
}
