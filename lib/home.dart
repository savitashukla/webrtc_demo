import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_video_call/webrtc_methods.dart';

class WebRtcHome extends StatefulWidget {
  const WebRtcHome({super.key});

  @override
  State<WebRtcHome> createState() => _WebRtcHomeState();
}

class _WebRtcHomeState extends State<WebRtcHome> {
  RTCPeerConnection? peerConnection;

  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCSessionDescription? _localSDP;
  List localICE = [];

  RTCSessionDescription? _remoteSDP;
  List remoteICE = [];

  Future createRoom() async {
    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      // TODO: copy ice candidates Data and send
      setState(() {
        localICE.add(candidate.toMap());
      });
    };
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    setState(() {
      _localSDP = offer;
    });
    // TODO: copy ice sdp offer and send
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
  }

  Future<void> joinRoom(Map remoteSDP, Map remoteIceCandidate) async {
    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      setState(() {
        remoteICE.add(candidate.toMap());
      });
    };
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };
    await peerConnection?.setRemoteDescription(
      RTCSessionDescription(remoteSDP['sdp'], remoteSDP['type']),
    );
    var answer = await peerConnection!.createAnswer();
    // Listening for remote ICE candidates below
    await peerConnection!.setLocalDescription(answer);
    setState(() {
      _remoteSDP = answer;
    });
    peerConnection!.addCandidate(
      RTCIceCandidate(
        remoteIceCandidate['candidate'],
        remoteIceCandidate['sdpMid'],
        remoteIceCandidate['sdpMLineIndex'],
      ),
    );
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false,
    });

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    localStream!.dispose();
    remoteStream?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox(),
    );
  }
}
