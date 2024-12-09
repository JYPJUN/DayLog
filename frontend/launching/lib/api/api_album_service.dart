import 'dart:convert';
import 'dart:io';
import 'package:daylog_launching/api/api_user_service.dart';
import 'package:daylog_launching/models/album/album_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart'; // basename을 위한 임포트

class ApiAlbumService {
  static const String baseUrl = "http://i11b107.p.ssafy.io:8080/api";

  // 앨범 등록
  static Future<void> saveAlbums({
    required List<File> files,
    required String date,
  }) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final uri = Uri.parse('$baseUrl/mediafiles');

    // 멀티파트 요청 생성
    final request = http.MultipartRequest('POST', uri);

    // JWT 토큰 설정
    request.headers['Authorization'] = 'Bearer $jwtToken';

    // 파일 추가
    for (File file in files) {
      // 파일 이름과 MIME 타입 추출
      final fileName = basename(file.path);
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      request.files.add(
        await http.MultipartFile.fromPath(
          'multipartFiles', // form-data의 키
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    // 날짜 추가
    request.fields['date'] = date;

    // 요청 전송 및 응답 처리
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // 응답 본문 읽기
        final responseBody = await response.stream.bytesToString();
        print('업로드 성공: $responseBody');
      } else {
        print('업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
    }
  }

  // 앨범 조회
  static Future<List<AlbumModel>> getAlbums(int year, int month) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    List<AlbumModel> albumsInstances = [];
    final response = await http.get(
      Uri.parse('$baseUrl/mediafiles/search?year=$year&month=$month'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> schedules =
          jsonDecode(utf8.decode(response.bodyBytes));
      for (var schedule in schedules) {
        albumsInstances.add(AlbumModel.fromJson(schedule));
      }
      return albumsInstances;
    } else {
      throw HttpException(
          'Failed to load schedule. Status code: ${response.statusCode}');
    }
  }

  // 앨범 삭제하기
  static Future<void> deleteAlbumByMediaFileId(int mediafileId) async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.delete(
      Uri.parse('$baseUrl/mediafiles/$mediafileId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken"
      },
    );
    if (response.statusCode != 200) {
      throw HttpException(
          'Failed to delete album. Status code: ${response.statusCode}');
    }
  }
}
