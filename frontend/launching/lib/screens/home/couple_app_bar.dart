import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daylog_launching/models/couple/couple_info.dart';
import 'package:daylog_launching/screens/home/anniversary_modal.dart';

class CoupleAppBar extends StatefulWidget {
  final String user1ProfileImagePath;
  final String user2ProfileImagePath;
  final String user1Name;
  final String user2Name;
  final int dDay;
  final String backgroundImagePath;
  final CoupleInfo coupleInfo; // Add this to pass CoupleInfo
  final VoidCallback refreshCoupleInfo; // Callback to refresh CoupleInfo

  const CoupleAppBar({
    super.key,
    required this.user1ProfileImagePath,
    required this.user2ProfileImagePath,
    required this.user1Name,
    required this.user2Name,
    required this.dDay,
    required this.backgroundImagePath,
    required this.coupleInfo,
    required this.refreshCoupleInfo,
  });

  @override
  _CoupleAppBarState createState() => _CoupleAppBarState();
}

class _CoupleAppBarState extends State<CoupleAppBar> {
  Color _textColor = Colors.white;
  late ImageProvider _backgroundImage;

  @override
  void initState() {
    super.initState();
    _backgroundImage = NetworkImage(
        'https://i11b107.p.ssafy.io/api/serve/image?path=${widget.backgroundImagePath}');
    _loadImage();
  }

  Future<void> _loadImage() async {
    final completer = Completer<ui.Image>();
    _backgroundImage.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));
    final image = await completer.future;
    _updateTextColor(image);
  }

  void _updateTextColor(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(200, 50); // Approximate size of the text area

    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.cover,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final buffer = byteData!.buffer.asUint8List();

    int totalBrightness = 0;
    for (int i = 0; i < buffer.length; i += 4) {
      final r = buffer[i];
      final g = buffer[i + 1];
      final b = buffer[i + 2];
      totalBrightness += ((r * 299) + (g * 587) + (b * 114)) ~/ 1000;
    }

    final averageBrightness = totalBrightness / (size.width * size.height);
    if (!mounted) return;
    setState(() {
      _textColor = averageBrightness > 128 ? Colors.black : Colors.white;
    });
  }

  void _showAnniversaryModal() {
    showAnniversaryModal(context, widget.coupleInfo, widget.refreshCoupleInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      'http://i11b107.p.ssafy.io/api/serve/image?path=${widget.user1ProfileImagePath}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    widget.user1Name,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    '${widget.dDay} 일 째',
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://i11b107.p.ssafy.io/api/serve/image?path=${widget.user2ProfileImagePath}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    widget.user2Name,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -10,
          child: GestureDetector(
            onTap: _showAnniversaryModal, // Wrap with GestureDetector
            child: SizedBox(
              width: 60,
              child: Lottie.asset(
                'assets/anime/heart2.json',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
