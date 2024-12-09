// api_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiUserService {
  static const String baseUrl = 'https://i11b107.p.ssafy.io/api';
  // 추가적인 API 요청 함수들 예시
  // static Future<void> someOtherApiCall() async {
  //   // 구현 내용
  // }

  // 로그인 API 호출 함수
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final String token = responseBody['accessToken'];
      await saveToken(token);
      return responseBody;
    } else {
      throw Exception('로그인 실패: ${response.statusCode}');
    }
  }

  // SharedPreferences에 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
  }

  // SharedPreferences에서 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  // 회원가입 API 호출 함수
  static Future<void> signUp(Map<String, String> userSignUpRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userSignUpRequest),
    );

    if (response.statusCode != 200) {
      throw Exception('회원가입 실패: ${response.statusCode}');
    }
  }

  //  비밀번호 검증
  static Future<bool> accountPasswordConfirm(String password) async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.post(
      Uri.parse('$baseUrl/users/check-duplicate/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'rawPassword': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['isDuplicate'];
    } else {
      throw Exception('비밀번호 검증 실패: ${response.statusCode}');
    }
  }

  // 회원 탈퇴 API 호출 메서드
  static Future<void> deleteAccount() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/users');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('회원 탈퇴 실패: ${response.statusCode}');
    }
  }

  // 회원 로그아웃 API 호출 메서드
  static Future<void> logOut() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/users/logout');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      print('로그아웃 완료: ${response.statusCode}');
    } else {
      print('로그아웃 실패: ${response.statusCode}');
    }
  }

  // 이메일 중복 검사 API 호출 함수
  static Future<bool> checkEmailDuplicate(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/check-duplicate/email?email=$email'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['isDuplicate'];
    } else {
      throw Exception('이메일 중복 검사 실패: ${response.statusCode}');
    }
  }

  // 휴대폰 번호 중복 검사 API 호출 함수
  static Future<bool> checkPhoneDuplicate(String phone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/check-duplicate/phone?phone=$phone'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['isDuplicate'];
    } else {
      throw Exception('핸드폰 번호 중복 검사 실패: ${response.statusCode}');
    }
  }

  // 회원 정보 보기
  static Future<Map<String, dynamic>> userInfo() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/users');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      // 응답이 성공적일 때 JSON 데이터를 파싱하여 반환
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('회원 정보 조회 실패: ${response.statusCode}');
    }
  }

  // 회원 알람 정보 보기
  static Future<List<dynamic>> alarmInfo() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/notifications');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    // 응답이 성공적일 때 JSON 데이터를 파싱하여 반환
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> parsedJson = json.decode(responseBody);
      print(parsedJson);
      return parsedJson;
    } else {
      throw Exception('알림 조회 실패: ${response.statusCode}');
    }
  }

  // 회원 알람 정보 보기
  static Future<List<dynamic>> alarmCheck() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/notifications');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    // 응답이 성공적일 때 JSON 데이터를 파싱하여 반환
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> parsedJson = json.decode(responseBody);
      for (var alarm in parsedJson) {
        print(alarm);
      }
      return parsedJson;
    } else {
      throw Exception('알림 조회 실패: ${response.statusCode}');
    }
  }

  // 회원 알람 개수 보기
  static Future<int> alarmCount() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/notifications/count');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    // 응답이 성공적일 때 JSON 데이터를 파싱하여 반환
    if (response.statusCode == 200) {
      final int responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('알림 조회 실패: ${response.statusCode}');
    }
  }

  // 커플 정보 보기
  static Future<Map<String, dynamic>> coupleInfo() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/couples');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      // 응답이 성공적일 때 JSON 데이터를 파싱하여 반환
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('회원 정보 조회 실패: ${response.statusCode}');
    }
  }

  // 회원 상태 변경
  static Future<bool> coupleStatusReplace() async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/users/update/user-status');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      print('PENDING-> INACTIVE 변경완료');
      return true;
    } else {
      throw false;
    }
  }

  // 회원 비밀번호 변경
  static Future<bool> updatePassword(String newPassword) async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/users/update/password');
    final response = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'newPassword': newPassword}));

    if (response.statusCode == 200) {
      print('비밀번호 변경 완료');
      return true;
    } else {
      throw false;
    }
  }

  // 회원 별명 변경
  static Future<bool> updateNickname(String newNickname) async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다');

    final url = Uri.parse('$baseUrl/users/update/name');
    final response = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'name': newNickname}));

    if (response.statusCode == 200) {
      print('닉네임 변경 완료');
      return true;
    } else {
      print('${response.statusCode}');
      throw Exception('닉네임 변경 실패: ${response.statusCode}');
    }
  }

  // 회원 이미지 변경
  static Future<void> updateProfileImage(File image) async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다');

    final url = Uri.parse('$baseUrl/users/update/profile-image');
    var request = http.MultipartRequest('PATCH', url);
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer $jwtToken';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('이미지 업로드 성공');
    } else {
      print('이미지 업로드 실패');
    }
  }

  // 커플 프로필 이미지 변경
  static Future<void> updateCoupleImage(File image) async {
    final String? jwtToken = await getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다');

    final url = Uri.parse('$baseUrl/couples/update/background-image');
    var request = http.MultipartRequest('PATCH', url);
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer $jwtToken';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    print(request);

    if (response.statusCode == 200) {
      print('이미지 업로드 성공');
    } else {
      print('이미지 업로드 실패');
    }
  }

  static Future<void> getNewToken() async {
    final String? jwtToken = await ApiUserService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/users/token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final responseBody = json.decode(response.body);
    final String token = responseBody['accessToken'];
    print("######################");
    print(token);
    await saveToken(token);
  }
}
