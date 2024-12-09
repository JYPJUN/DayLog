import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:daylog_launching/api/api_couple_service.dart';
import 'package:daylog_launching/models/couple/couple_info.dart';
import 'dart:convert';

class AnniversaryModal extends StatefulWidget {
  final CoupleInfo coupleInfo;
  final VoidCallback onDateSelected;

  const AnniversaryModal({
    super.key,
    required this.coupleInfo,
    required this.onDateSelected,
  });

  @override
  State<AnniversaryModal> createState() => _AnniversaryModalState();
}

class _AnniversaryModalState extends State<AnniversaryModal> {
  late DateTime selectedDate;
  late DateTime tempPickedDate; // 임시 날짜 변수

  @override
  void initState() {
    super.initState();
    selectedDate = widget.coupleInfo.relationshipStartDate;
    tempPickedDate = selectedDate; // 초기값을 selectedDate와 동일하게 설정
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              _buildBody(),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        const Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                'D-Day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        tempPickedDate = newDate;
                      });
                    },
                    dateOrder: DatePickerDateOrder.ymd,
                    itemExtent: 45.0,
                  ),
                ),
              ),
              CupertinoButton(
                child: const Text('변경하기'),
                onPressed: () async {
                  try {
                    // API 호출
                    await ApiCoupleService.updateRelationshipStartDate(
                        tempPickedDate);

                    // 최종 날짜 업데이트
                    setState(() {
                      selectedDate = tempPickedDate;
                    });

                    // 부모 위젯에 알림
                    widget.onDateSelected();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error updating date: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildProfileRow(),
        const SizedBox(height: 16.0),
        const Text(
          '처음 만난 날',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                DateFormat('yyyy. M. d').format(selectedDate),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            Positioned(
              right: 65, // 중앙에서 약간 오른쪽으로 위치 조정
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showDatePicker(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfileColumn(
          imagePath: widget.coupleInfo.user1ProfileImagePath,
          name: utf8.decode(widget.coupleInfo.user1Name.runes.toList()),
        ),
        const SizedBox(width: 16.0),
        const Icon(Icons.favorite, color: Colors.red, size: 24),
        const SizedBox(width: 16.0),
        _buildProfileColumn(
          imagePath: widget.coupleInfo.user2ProfileImagePath,
          name: utf8.decode(widget.coupleInfo.user2Name.runes.toList()),
        ),
      ],
    );
  }

  Widget _buildProfileColumn(
      {required String imagePath, required String name}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
              'https://i11b107.p.ssafy.io/api/serve/image?path=$imagePath'),
        ),
        const SizedBox(height: 8.0),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

void showAnniversaryModal(
    BuildContext context, CoupleInfo coupleInfo, VoidCallback onDateSelected) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AnniversaryModal(
        coupleInfo: coupleInfo,
        onDateSelected: onDateSelected,
      );
    },
    barrierDismissible: true,
  );
}
