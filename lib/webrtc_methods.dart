import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class WebRtcMethods {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  List localColletion = [];
  List remoteCollection = [];

  Future createRoom() async {
    peerConnection = await createPeerConnection(configuration);

    // registerPeerConnectionListeners(peerConnection);

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      // TODO: copy ice candidates Data and send
      localColletion.add(candidate.toMap());
    };
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    // TODO: copy ice sdp offer and send
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
  }

  Future setRemoteSdp(Map<String, dynamic> data) async {
    var answer = RTCSessionDescription(
      data['answer']['sdp'],
      data['answer']['type'],
    );
    await peerConnection?.setRemoteDescription(answer);
  }

  Future addIceCandidate(Map<String, dynamic> data) async {
    await peerConnection!.addCandidate(
      RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      ),
    );
  }

  Future<void> joinRoom(Map remoteSDP, Map remoteIceCandidate) async {
    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      remoteCollection.add(candidate.toMap());
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
    peerConnection!.addCandidate(
      RTCIceCandidate(
        remoteIceCandidate['candidate'],
        remoteIceCandidate['sdpMid'],
        remoteIceCandidate['sdpMLineIndex'],
      ),
    );
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    localStream!.dispose();
    remoteStream?.dispose();
  }
}

Map<String, dynamic> configuration = {
  'iceServers': [
    {
      'urls': ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302']
    }
  ]
};

void registerPeerConnectionListeners(
  RTCPeerConnection? peerConnection, {
  required MediaStream? remoteStream,
  required StreamStateCallback? onAddRemoteStream,
}) {
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
  MediaStream? localStream,
) async {
  var stream = await navigator.mediaDevices.getUserMedia({
    'video': true,
    'audio': false,
  });

  localVideo.srcObject = stream;
  localStream = stream;

  remoteVideo.srcObject = await createLocalMediaStream('key');
}
