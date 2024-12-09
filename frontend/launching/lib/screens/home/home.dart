import 'package:daylog_launching/api/api_couple_service.dart';
import 'package:daylog_launching/models/couple/couple_info.dart';
import 'package:daylog_launching/screens/home/couple_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:daylog_launching/screens/home/anniversary_modal.dart';
import '../../api/api_user_service.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  CoupleInfo? coupleInfo;
  Key _coupleAppBarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _setupCoupleInfo();
  }

  void _setupCoupleInfo() async {
    final info = await ApiCoupleService.getCoupleInfo();
    if (mounted) {
      setState(() {
        coupleInfo = info;
      });
    }
  }

  void _refreshCoupleInfo() async {
    final updatedInfo = await ApiCoupleService.getCoupleInfo();
    if (mounted) {
      setState(() {
        coupleInfo = updatedInfo;

        _coupleAppBarKey = UniqueKey(); // Force rebuild of CoupleAppBar
      });
    }
  }

  bool isProcessing = false;
  Future<void> _changeProfileImage() async {
    if (isProcessing) return; // 이미 함수가 실행 중이면 중복 실행을 방지

    setState(() {
      isProcessing = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => image = File(pickedFile.path));
        await ApiUserService.updateCoupleImage(image!);
        _refreshCoupleInfo();
      }
    } catch (e) {
      print('오류발생: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('사진 찍기'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() => image = File(pickedFile.path));
                    await ApiUserService.updateCoupleImage(image!);
                    _refreshCoupleInfo();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('앨범 선택'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() => image = File(pickedFile.path));
                    await ApiUserService.updateCoupleImage(image!);
                    _refreshCoupleInfo();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDay(CoupleInfo coupleInfo) {
    showAnniversaryModal(context, coupleInfo, _refreshCoupleInfo);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    if (coupleInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://i11b107.p.ssafy.io/api/serve/image?path=${coupleInfo!.backgroundImagePath}',
            fit: BoxFit.cover,
          ),
          FractionallySizedBox(
            alignment: const Alignment(0, -0.95),
            heightFactor: 0.2,
            child: CoupleAppBar(
              key: _coupleAppBarKey,
              user1ProfileImagePath: coupleInfo!.user1ProfileImagePath,
              user2ProfileImagePath: coupleInfo!.user2ProfileImagePath,
              user1Name: utf8.decode(coupleInfo!.user1Name.runes.toList()),
              user2Name: utf8.decode(coupleInfo!.user2Name.runes.toList()),
              dDay: _calculateDDay(coupleInfo!.relationshipStartDate),
              backgroundImagePath: coupleInfo!.backgroundImagePath,
              coupleInfo: coupleInfo!,
              refreshCoupleInfo: _refreshCoupleInfo,
            ),
          ),
          _buildBottomIcons(coupleInfo!),
        ],
      ),
    );
  }

  int _calculateDDay(DateTime startDate) {
    DateTime today = DateTime.now();
    int daysDifference = today.difference(startDate).inDays + 1;
    return daysDifference > 0 ? daysDifference : 1;
  }

  Widget _buildBottomIcons(CoupleInfo coupleInfo) {
    return Row(
      children: [
        _buildBottomIcon(
          icon: Icons.cake,
          onTap: () => _openDay(coupleInfo),
        ),
        _buildBottomIcon(
          icon: Icons.add_photo_alternate_outlined,
          onTap: _showImagePickerModal, // 수정된 부분
        ),
      ],
    );
  }

  Widget _buildBottomIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 15),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(116, 0, 0, 0),
            radius: 20,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
