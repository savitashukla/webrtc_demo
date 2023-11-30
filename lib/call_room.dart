import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_video_call/webrtc_methods.dart';

class CallRoom extends StatefulWidget {
  StreamStateCallback? onAddRemoteStream;
  MediaStream? localStream;
  MediaStream? remoteStream;
  CallRoom({
    super.key,
    this.onAddRemoteStream,
    this.localStream,
    this.remoteStream,
  });

  @override
  State<CallRoom> createState() => _CallRoomState();
}

class _CallRoomState extends State<CallRoom> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  @override
  void initState() {
    // _localRenderer.initialize();
    // _remoteRenderer.initialize();

    // openUserMedia(
    //   _localRenderer,
    //   _remoteRenderer,
    //   widget.localStream,
    // ).then((value) => {});
    // setState(() {});

    // widget.onAddRemoteStream = ((stream) {
    //   _remoteRenderer.srcObject = stream;
    //   setState(() {});
    // });

    initRenderers();
    super.initState();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _localRenderer.srcObject = widget.localStream;
    _remoteRenderer.srcObject = widget.remoteStream;

    setState(() {
      
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 150,
              width: 120,
              child: RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
