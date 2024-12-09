import 'dart:io';
import 'package:daylog_launching/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openvidu_flutter/participant/local_participant.dart';
import 'package:openvidu_flutter/participant/participant.dart';
import 'package:openvidu_flutter/utils/custom_websocket.dart';
import 'package:openvidu_flutter/utils/session.dart';
import 'package:openvidu_flutter/utils/utils.dart';
import 'package:daylog_launching/api/api_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class VideocallWidget extends StatefulWidget {
  const VideocallWidget({
    super.key,
    required this.server,
    required this.sessionId,
    required this.userName,
    required this.secret,
    required this.iceServer,
  });

  final String server;
  final String sessionId;
  final String userName;
  final String secret;
  final String iceServer;

  @override
  State<VideocallWidget> createState() => _VideocallWidgetState();
}

class _VideocallWidgetState extends State<VideocallWidget> {
  late ApiService apiService;
  Session? session;
  bool _isHangUp = false;

  // 현재 화면 위치 상태 (true: 로컬 화면이 위, false: 로컬 화면이 아래)
  bool _isLocalVideoOnTop = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(widget.sessionId, widget.server, widget.secret,
        (X509Certificate cert, String host, int port) => true);
    _connect();
  }

  void _hangUp() async {
    if (_isHangUp) {
      return;
    }

    _isHangUp = true;

    if (session != null) {
      session!.leaveSession();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const App()));
    }
  }

  void _switchCamera() {
    session?.localParticipant?.switchCamera().then((value) {
      if (mounted) {
        refresh();
      }
    });
  }

  void _toggleVideo() {
    session?.localToggleVideo();
    if (mounted) {
      refresh();
    }
  }

  void _toggleMic() {
    session?.localToggleAudio();
    if (mounted) {
      refresh();
    }
  }

  void _swichPosition() {
    setState(() {
      _isLocalVideoOnTop = !_isLocalVideoOnTop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  @override
  void dispose() {
    if (!_isHangUp && session != null) {
      session!.leaveSession();
    }
    super.dispose();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void startWebSocket() {
    CustomWebSocket webSocket = CustomWebSocket(
      session!,
      customClient: HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true,
    );
    webSocket.onErrorEvent = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    };
    webSocket.connect();
    session?.setWebSocket(webSocket);
  }

  Future<void> _connect() async {
    apiService.createSession().then((sessionId) {
      apiService.createToken().then((token) {
        session = Session(sessionId, token);
        session?.messageStream.listen((message) {
          setState(() {});
        });

        session!.onNotifySetRemoteMediaStream = (String connectionId) {
          refresh();
        } as OnNotifySetRemoteMediaStreamEvent?;
        session!.onAddRemoteParticipant = (String connectionId) {
          refresh();
        } as OnAddRemoteParticipantEvent?;
        session!.onRemoveRemoteParticipant = (String connectionId) {
          refresh();
          _hangUp();
        } as OnRemoveRemoteParticipantEvent?;

        session!.onParticipantLeft = (String connectionId) {
          _hangUp();
        };

        var localParticipant = LocalParticipant(widget.userName, session!);
        localParticipant.renderer.initialize().then((value) {
          localParticipant.startLocalCamera().then((stream) => refresh());
        });

        startWebSocket();
      }).catchError((error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
      });
    });
  }

  Widget _body() {
    var remoteParticipants = session?.remoteParticipants.entries ?? [];

    return Stack(
      children: [
        Column(
          children: <Widget>[
            Expanded(
              child: remoteParticipants.isEmpty
                  ? Column(children: [buildLocalRenderer(fullScreen: true)])
                  : remoteParticipants.length == 1
                      ? Column(
                          children: [
                            if (_isLocalVideoOnTop)
                              Expanded(child: buildLocalRenderer()),
                            Expanded(
                              child: buildRendererContainer(
                                  remoteParticipants.elementAt(0)),
                            ),
                            if (!_isLocalVideoOnTop)
                              Expanded(child: buildLocalRenderer()),
                          ],
                        )
                      : remoteParticipants.length == 2
                          ? Row(
                              children:
                                  remoteParticipants.map((participantPair) {
                                return Expanded(
                                    child: buildRendererContainer(
                                        participantPair));
                              }).toList(),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(0.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 1.0,
                                mainAxisSpacing: 1.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: remoteParticipants.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    buildRendererContainer(
                                        remoteParticipants.elementAt(index)),
                                  ],
                                );
                              },
                            ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0), // 원하는 패딩 값을 지정하세요.
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width * 0.95, // 가로의 95%만 차지하도록 설정
              child: _buttons(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocalRenderer({bool fullScreen = false}) {
    if (session?.localParticipant?.renderer == null) {
      if (fullScreen) {
        return const Expanded(
            child: Center(child: CircularProgressIndicator()));
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (fullScreen) {
      return Expanded(child: buildLocalRendererBody(fullScreen: fullScreen));
    }

    return buildLocalRendererBody(fullScreen: fullScreen);
  }

  Widget buildLocalRendererBody({bool fullScreen = true}) {
    return Container(
      width: fullScreen ? null : double.infinity,
      height: fullScreen ? null : double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                session!.localParticipant!.isVideoActive
                    ? RTCVideoView(
                        session!.localParticipant!.renderer,
                        mirror:
                            session?.localParticipant?.isFrontCameraActive ??
                                false,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : _noVideoInitial(
                        session!.localParticipant!.participantName, fullScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRendererContainer(MapEntry<String, Participant> remotePair) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: RTCVideoView(
          remotePair.value.renderer,
          objectFit: RTCVideoViewObjectFit
              .RTCVideoViewObjectFitCover, // 비율 유지 + 화면 꽉 차게 하기
        ),
      ),
    );
  }

  Widget _noVideoInitial(String participantName, [bool fullScreen = true]) {
    var randomColor = getColorFromString(participantName);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: fullScreen ? 150.0 : 50.0,
            height: fullScreen ? 150.0 : 50.0,
            decoration: BoxDecoration(
              color: randomColor.withOpacity(0.5),
              border: Border.all(color: randomColor, width: 3.0),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Center(
              child: Lottie.asset(
                'assets/videocall/cat2.json',
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buttons() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _noHeroFloatingActionButton(
              onPressed: _toggleVideo,
              tooltip: session?.localParticipant?.isVideoActive ?? true
                  ? 'Turn on video'
                  : 'Turn off video',
              icon: Icon(
                session?.localParticipant?.isVideoActive ?? true
                    ? Icons.videocam
                    : Icons.videocam_off,
                color: Colors.white,
              ),
            ),
            _noHeroFloatingActionButton(
              onPressed: _toggleMic,
              tooltip: session?.localParticipant?.isAudioActive ?? true
                  ? 'Mute Mic'
                  : 'Unmute Mic',
              icon: Icon(
                session?.localParticipant?.isAudioActive ?? true
                    ? Icons.mic
                    : Icons.mic_off,
                color: Colors.white,
              ),
            ),
            _noHeroFloatingActionButton(
              onPressed: _hangUp,
              tooltip: 'Hang Up',
              icon: const Icon(
                Icons.call_end,
                color: Colors.red,
              ),
            ),
            if (session?.localParticipant?.isVideoActive ?? true)
              _noHeroFloatingActionButton(
                onPressed: _switchCamera,
                tooltip: 'Switch Camera',
                icon: const Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                ),
              ),
            _noHeroFloatingActionButton(
              onPressed: _swichPosition,
              tooltip: 'Switch Position', // 위치 변경
              icon: const Icon(
                Icons.swap_vert,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noHeroFloatingActionButton({
    required VoidCallback onPressed,
    required String tooltip,
    required Icon icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Tooltip(
        message: tooltip,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double buttonSize = MediaQuery.of(context).size.width *
                0.125; // 가로 길이의 12.5%를 버튼 크기로 설정
            return Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(buttonSize / 3), // 비율에 따라 원형으로 만들기
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(140, 0, 0, 0),
                    Color.fromARGB(255, 0, 0, 0)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Center(child: icon),
            );
          },
        ),
      ),
    );
  }
}
