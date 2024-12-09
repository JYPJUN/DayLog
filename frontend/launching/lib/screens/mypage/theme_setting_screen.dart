import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingScreen extends StatelessWidget {
  const ThemeSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // 뒤로가기 화살표 색상
        ),
        title: const Text(
          'My Theme',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.themeColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildThemeRow(
                context,
                'default',
                '시스템 설정 (기본 설정)',
                const Color(0xFFff9292),
                Colors.white,
              ),
              const SizedBox(height: 20),
              _buildThemeRow(
                context,
                'theme1',
                '보라 테마',
                const Color(0xFFc796fc),
                const Color(0xFFfcfaff),
              ),
              const SizedBox(height: 20),
              _buildThemeRow(
                context,
                'theme2',
                '분홍 테마',
                const Color.fromARGB(255, 255, 161, 210),
                const Color(0xFFfff6fa),
              ),
              const SizedBox(height: 20),
              _buildThemeRow(
                context,
                'theme3',
                '하늘 테마',
                const Color(0xFF87ceeb),
                const Color(0xFFf3fafd),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeRow(BuildContext context, String themeKey, String themeName,
      Color color, Color bgColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isSelected = themeProvider.selectedTheme == themeKey;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, bgColor],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? themeProvider.themeColor.withOpacity(0.3)
                    : Colors.black38.withOpacity(0.1),
                offset: isSelected ? const Offset(5, 5) : const Offset(2, 2),
                blurRadius: isSelected ? 15 : 5,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(themeName),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? themeProvider.themeColor : Colors.grey,
          ),
          onPressed: () async {
            await themeProvider.setTheme(themeKey, color, bgColor);
          },
        ),
      ],
    );
  }
}
