import 'package:daylog_launching/api/api_user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({super.key});

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  List<Map<String, String>> notices = [];
  List<bool> _isExpanded = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {
      final fetchedNotices = await getNoty();
      setState(() {
        notices = fetchedNotices;
        _isExpanded = List.filled(notices.length, false);
        _isLoading = false;
      });
    } catch (e) {
      // 에러 처리
      setState(() {
        _isLoading = false;
      });
      print('Failed to load notices: $e');
    }
  }

  // 전체 공지사항 정보를 가져오는 함수
  static Future<List<Map<String, String>>> getNoty() async {
    final String? jwtToken = await ApiUserService.getToken();
    if (jwtToken == null) throw Exception('토큰이 없습니다.');

    final response = await http.get(
      Uri.parse('https://i11b107.p.ssafy.io/api/announcements'),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $jwtToken"
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, String>> notices = data.map<Map<String, String>>((item) {
        return {
          'title': item['title'] as String,
          'date': item['createdAt'] as String,
          'content': item['content'] as String,
        };
      }).toList();
      return notices;
    } else {
      throw HttpException(
          'Failed to load notifications. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    late Color themeColor;
    late Color backColor;

    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    backColor = themeProvider.backColor;

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // 뒤로가기 화살표 색상
        ),
        title: const Text(
          '공지사항',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      title: Text(
                        notices[index]['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        notices[index]['date']!,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Icon(
                        _isExpanded[index]
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isExpanded[index] = expanded;
                        });
                      },
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            notices[index]['content']!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
