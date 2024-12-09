import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class MainCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final Map<DateTime, List<dynamic>> eventLoader;
  final ValueChanged<DateTime> onPageChanged;
  final Map<DateTime, List<dynamic>> albumLoader;
  final Map<DateTime, List<dynamic>> clipLoader;

  const MainCalendar({
    super.key,
    required this.onDaySelected,
    required this.selectedDate,
    required this.eventLoader,
    required this.onPageChanged,
    required this.albumLoader,
    required this.clipLoader,
  });

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base font size proportional to screen width
    final baseFontSize = screenWidth * 0.045;

    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return TableCalendar(
      locale: 'ko_kr',
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: '월', // Changed from "Month" to "월"
        CalendarFormat.week: '주', // Changed from "Week" to "주"
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay, focusedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onPageChanged(focusedDay);
      },
      daysOfWeekHeight: 20,
      selectedDayPredicate: (date) =>
          date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month &&
          date.day == widget.selectedDate.day,
      focusedDay: _focusedDay,
      firstDay: DateTime(1800, 1, 1),
      lastDay: DateTime(2500, 1, 1),
      eventLoader: (day) => widget.eventLoader[day] ?? [],
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final albumEvents = widget.albumLoader[date] ?? [];
          final totalCount = events.length + albumEvents.length; // 일정과 앨범 개수 합산

          if (totalCount > 0) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$totalCount', // 합산된 개수 표시
                    style: const TextStyle().copyWith(
                      color: Colors.white,
                      fontSize: baseFontSize * 0.7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }
          return null;
        },
        defaultBuilder: (context, date, focusedDay) {
          bool hasClip = widget.clipLoader[date] != null &&
              widget.clipLoader[date]!.isNotEmpty; // 하이라이트가 있는지 확인

          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: hasClip
                  ? themeColor.withOpacity(0.2)
                  : Colors.grey[200], // 하이라이트가 있는 경우 색상 변경
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: hasClip ? themeColor : Colors.grey[600], // 글자 색상 변경
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: themeColor, width: 2),
        ),
        formatButtonTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: baseFontSize * 0.9,
          color: themeColor,
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: baseFontSize * 1.1,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
        leftChevronPadding: EdgeInsets.zero, // 왼쪽 화살표 패딩 조정
        rightChevronPadding: EdgeInsets.zero, // 오른쪽 화살표 패딩 조정
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        defaultDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.grey[200],
        ),
        weekendDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.grey[200],
        ),
        selectedDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          border: Border.all(
            color: themeColor,
            width: 2,
          ),
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6),
          color: themeColor,
        ),
        defaultTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        weekendTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        selectedTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        outsideDecoration: const BoxDecoration(
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }
}
