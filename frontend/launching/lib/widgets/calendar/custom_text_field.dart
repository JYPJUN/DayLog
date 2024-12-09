import 'package:daylog_launching/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart'; // import dropdown_button2
// provider import
import 'package:provider/provider.dart';
import 'package:daylog_launching/providers/theme_provider.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isTime; // 시간 선택하는 텍스트 필드인지 여부
  final String? initialValue; // 초기값
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final bool enabled; // 활성화 여부를 설정하기 위한 필드

  const CustomTextField({
    required this.label,
    required this.isTime,
    this.initialValue,
    required this.onSaved,
    required this.validator,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 변수명 설정
    late Color themeColor;
    // late Color backColor;

// Provider 객체에서 색상 가져오기 (build 안에서 진행)
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeColor = themeProvider.themeColor;
    // backColor = themeProvider.backColor;

    return Column(
      // ➋ 세로로 텍스트와 텍스트 필드를 위치
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime)
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              fillColor: LIGHT_GREY_COLOR,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // borderRadius만 설정
                borderSide: BorderSide.none, // 테두리 선을 없앰
              ),
              enabled: enabled, // 활성화 여부에 따라 입력 가능
            ),
            hint: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.08),
              child: Text(
                'Select Time',
                style: TextStyle(
                  color: DARK_GREY_COLOR,
                ),
              ),
            ),
            value: initialValue,
            items: List.generate(24, (index) => index.toString())
                .map(
                  (time) => DropdownMenuItem<String>(
                    value: time,
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.04),
                      child: Text(
                        '$time 시',
                        style: TextStyle(
                          color: DARK_GREY_COLOR,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) {
              return List.generate(24, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.08),
                  child: Text(
                    '${index.toString()} 시',
                    style: TextStyle(
                      color: DARK_GREY_COLOR,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              });
            },
            validator: validator,
            onChanged: enabled // enabled가 true일 때만 값 변경 처리
                ? (value) {
                    // 선택된 값이 변경될 때 처리할 로직
                    if (value != null) {
                      // 선택된 값을 저장하거나 처리하는 로직
                      onSaved(value);
                    }
                  }
                : null,
            onSaved: onSaved,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(Icons.arrow_drop_down, color: DARK_GREY_COLOR),
              iconSize: screenWidth * 0.07,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: screenHeight * 0.3,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: screenHeight * 0.07, // 아이템 높이는 최소 48 이상이어야 함
            ),
          )
        else // 일반 텍스트 필드
          Expanded(
            child: TextFormField(
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              onSaved: onSaved,
              validator: validator,
              cursorColor: Colors.grey,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              initialValue: initialValue,
              enabled: enabled, // 활성화 여부에 따라 입력 가능
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: LIGHT_GREY_COLOR,
              ),
            ),
          ),
      ],
    );
  }
}
