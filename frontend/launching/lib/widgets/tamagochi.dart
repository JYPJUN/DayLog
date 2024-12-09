import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:convert';

class TamagotchiWidget extends StatefulWidget {
  const TamagotchiWidget({super.key});

  @override
  TamagotchiWidgetState createState() => TamagotchiWidgetState();
}

class TamagotchiWidgetState extends State<TamagotchiWidget> {
  late SpriteSheet spriteSheet;
  NodeWithSize? rootNode;
  late TamagotchiChat tamagotchiChat;
  bool isLoading = true;
  List<String> phrases = [];
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    loadSpriteSheet();
    loadPhrases();
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  void loadSpriteSheet() async {
    ImageMap images = ImageMap();
    await images.load(<String>[
      'assets/tamagochi/frame1.png',
      'assets/tamagochi/frame2.png',
      'assets/tamagochi/frame3.png',
      'assets/tamagochi/frame4.png',
      'assets/tamagochi/frame5.png',
      'assets/tamagochi/frame6.png',
      'assets/tamagochi/frame7.png',
      'assets/tamagochi/frame8.png',
      'assets/tamagochi/frame9.png',
    ]);

    if (!mounted) return; // State가 여전히 활성 상태인지 확인합니다.

    final json = {
      "frames": [
        {
          "filename": "frame1.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame2.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame3.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame4.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame5.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame6.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame7.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame8.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
        {
          "filename": "frame9.png",
          "frame": {"x": 0, "y": 0, "w": 150, "h": 150},
          "rotated": false,
          "trimmed": false,
          "spriteSourceSize": {"x": 0, "y": 0, "w": 64, "h": 64},
          "sourceSize": {"w": 64, "h": 64},
          "pivot": {"x": 0.5, "y": 0.5}
        },
      ]
    };

    spriteSheet = SpriteSheet(
      image: images['assets/tamagochi/frame1.png']!,
      jsonDefinition: jsonEncode(json),
    );

    rootNode = NodeWithSize(const Size(100.0, 100.0));
    tamagotchiChat = TamagotchiChat(images, spriteSheet, context, phrases);
    rootNode!.addChild(tamagotchiChat);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadPhrases() async {
    final phrasesString = await DefaultAssetBundle.of(context)
        .loadString('assets/tamagochi/tamagochi.txt');
    if (!mounted) return; // State가 여전히 활성 상태인지 확인합니다.
    setState(() {
      phrases = phrasesString
          .split('\n')
          .where((phrase) => phrase.trim().isNotEmpty)
          .toList();
    });
  }

  void handleTap() {
    tamagotchiChat.handleTap();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: handleTap,
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.transparent,
          child: SpriteWidget(rootNode!),
        ),
      ),
    );
  }
}

class TamagotchiChat extends Node {
  final ImageMap images;
  final SpriteSheet spriteSheet;
  final BuildContext buildContext;
  final List<String> phrases;
  late List<Sprite> frames;
  late Sprite sprite;
  int currentFrame = 0;
  double frameTime = 0.18;
  double elapsedTime = 0.0; // 초기값 수정

  TamagotchiChat(
      this.images, this.spriteSheet, this.buildContext, this.phrases) {
    frames = List.generate(9, (index) {
      return Sprite.fromImage(images['assets/tamagochi/frame${index + 1}.png']!)
        ..pivot = const Offset(0, 0);
    });
    sprite = frames[currentFrame];
    addChild(sprite);

    userInteractionEnabled = true;
    print(
        'userInteractionEnabled: $userInteractionEnabled'); // userInteractionEnabled 로그 추가
  }

  @override
  void update(double dt) {
    elapsedTime += dt;
    if (elapsedTime >= frameTime) {
      elapsedTime = 0.0;
      currentFrame = (currentFrame + 1) % frames.length;
      removeChild(sprite);
      sprite = frames[currentFrame];
      addChild(sprite);
    }
    super.update(dt);
  }

  void handleTap() {
    print("Sprite clicked!"); // 클릭 이벤트 로그 추가
    if (phrases.isNotEmpty) {
      final phrase = phrases[DateTime.now().millisecond % phrases.length];
      _showBalloon(phrase);
    } else {
      _showBalloon('No phrases available.');
    }
  }

  void _showBalloon(String message) {
    print("Showing balloon: $message"); // 말풍선 표시 로그 추가
    final overlay = Overlay.of(buildContext);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 150,
        top: 180,
        child: BalloonWidget(message: message),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

class BalloonWidget extends StatelessWidget {
  final String message;

  const BalloonWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
