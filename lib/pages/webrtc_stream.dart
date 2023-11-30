// _setupPeerConnection() async {
//   // // videoRenderer for localPeer
//   // final localRTCVideoRenderer = RTCVideoRenderer();

//   // // videoRenderer for remotePeer
//   // final remoteRTCVideoRenderer = RTCVideoRenderer();
//   // MediaStream? localStream;

//   // // RTC peer connection
//   // RTCPeerConnection? rtcPeerConnection0;

//   // // list of rtcCandidates to be sent over signalling
//   // List<RTCIceCandidate> rtcIceCadidates = [];

//   // // media status

//   // create peer connection

//   // // listen for remotePeer mediaTrack event
//   // rtcPeerConnection.onTrack = (event) {
//   //   remoteRTCVideoRenderer.srcObject = event.streams[0];
//   // };

//   // // get localStream
//   // localStream = await navigator.mediaDevices.getUserMedia({
//   //   'audio': isAudioOn,
//   //   'video': {'facingMode': isFrontCameraSelected ? 'user' : 'environment'},
//   // });

//   // // add mediaTrack to peerConnection
//   // localStream.getTracks().forEach((track) {
//   //   rtcPeerConnection!.addTrack(track, localStream!);
//   // });

//   // // set source for local video renderer
//   // localRTCVideoRenderer.srcObject = localStream;
// }
