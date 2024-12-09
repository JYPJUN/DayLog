import 'package:daylog_launching/screens/calendar/calendar_screen.dart';
import 'package:daylog_launching/screens/diary/diary_screen.dart';
import 'package:daylog_launching/screens/home/home.dart';
import 'package:daylog_launching/screens/mypage/mypage_screen.dart';
import 'package:daylog_launching/screens/videocall/loading_call.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class Footer extends StatefulWidget {
  final int selectedIndex;

  const Footer({super.key, this.selectedIndex = 0});

  @override
  FooterState createState() => FooterState();
}

class FooterState extends State<Footer> {
  late int selectedIndex;
  late PageController _pageController;
  late Color themeColor;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ThemeProvider를 didChangeDependencies에서 접근
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 150),
      curve: Curves.bounceIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            children: const <Widget>[
              Center(child: Home()),
              Center(child: CalendarScreen()),
              Center(child: LoadingCall()),
              Center(child: DiaryScreen()),
              Center(child: MypageScreen()),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: 60,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex * (MediaQuery.of(context).size.width / 5),
                child: Container(
                  width: MediaQuery.of(context).size.width / 5,
                  height: 4,
                  color: themeColor,
                ),
              ),
              Row(
                children: [
                  _buildBarItem(Icons.home, 0, '홈', themeColor),
                  _buildBarItem(Icons.calendar_month, 1, '캘린더', themeColor),
                  _buildBarItem(
                      Icons.video_camera_front_outlined, 2, '통화', themeColor),
                  _buildBarItem(Icons.book, 3, '일기', themeColor),
                  _buildBarItem(Icons.menu, 4, '마이페이지', themeColor),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Expanded _buildBarItem(
      IconData icon, int index, String label, Color themeColor) {
    bool isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? themeColor : themeColor.withOpacity(0.65),
                size: 28,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? themeColor : themeColor.withOpacity(0.65),
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
