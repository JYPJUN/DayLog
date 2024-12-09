import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:daylog_launching/screens/videocall/videocall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrepareVideocall extends StatefulWidget {
  const PrepareVideocall({super.key});

  @override
  State<PrepareVideocall> createState() => _PrepareVideocallState();
}

class _PrepareVideocallState extends State<PrepareVideocall> {
  final Logger _logger = Logger('PrepareVideocall');

  bool isOnline = false;
  late TextEditingController _textSessionController;
  late TextEditingController _textUserNameController;
  late TextEditingController _textUrlController;
  late TextEditingController _textSecretController;
  late TextEditingController _textPortController;
  late TextEditingController _textIceServersController;

  // user 정보
  String? token;
  String? coupleId;
  String? userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('jwt_token');
    });
    if (token != null) {
      await userInfo();
    }
    _initializeControllers();
    _loadSharedPref();
    _liveConn();
  }

  Future<void> userInfo() async {
    final response = await http.get(
      Uri.parse('http://i11b107.p.ssafy.io:8080/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userId = data["userId"].toString();
        coupleId = data["coupleId"].toString();
      });
    } else {
      print('Failed : ${response.statusCode}');
    }
  }

  void _initializeControllers() {
    // userId와 coupleId 값으로 초기화
    _textSessionController = TextEditingController(text: coupleId);
    _textUserNameController = TextEditingController(text: userId);
    _textUrlController =
        TextEditingController(text: 'demos.openvidu.io'); // Default Value
    _textSecretController = TextEditingController(text: coupleId);
    _textPortController = TextEditingController(text: '443'); // Default Value
    _textIceServersController =
        TextEditingController(text: 'stun.l.google.com:19302'); // Default Value

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _textUrlController.text =
          prefs.getString('textUrl') ?? _textUrlController.text;
      _textSecretController.text =
          prefs.getString('textSecret') ?? _textSecretController.text;
      _textPortController.text =
          prefs.getString('textPort') ?? _textPortController.text;
      _textIceServersController.text =
          prefs.getString('textIceServers') ?? _textIceServersController.text;
    });
  }

  Future<void> _saveSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('textUrl', _textUrlController.text);
    await prefs.setString('textSecret', _textSecretController.text);
    await prefs.setString('textPort', _textPortController.text);
    await prefs.setString('textIceServers', _textIceServersController.text);
  }

  void _navigateToVideocall() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      _saveSharedPref();
      return VideocallWidget(
        server: '${_textUrlController.text}:${_textPortController.text}',
        sessionId: _textSessionController.text,
        userName: _textUserNameController.text,
        secret: _textSecretController.text,
        iceServer: _textIceServersController.text,
      );
    }));
  }

  Future<void> _liveConn() async {
    await _checkOnline();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkOnline();
    });
  }

  Future<void> _checkOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!isOnline) {
          isOnline = true;
          setState(() {});
          _logger.info('Online..');
          _navigateToVideocall();
        }
      }
    } on SocketException catch (_) {
      if (isOnline) {
        isOnline = false;
        setState(() {});
        _logger.info('..Offline');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 로딩 인디케이터를 표시
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // 로딩이 끝나면 빈 화면 반환 (추후에 필요한 위젯으로 대체)
    return const Text(''); // 화면 구현 X
  }
}
