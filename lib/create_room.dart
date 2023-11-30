import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_room.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({
    super.key,
  });

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  RTCSessionDescription? _localSDP;
  final List _localICE = [];
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  Future initiateWebRtc() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };
    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onConnectionState =(state) {
      print("connection state: $state");
    };

    _peerConnection?.onTrack = (event) {
      print("setting the remote stream");
      remoteStream = event.streams[0];
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'user'},
      'audio': false,
    });

    localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, localStream!);
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      setState(() {
        _localICE.add(candidate.toMap());
      });
    };
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    setState(() {
      _localSDP = offer;
    });
  }

  @override
  void initState() {
    super.initState();
    initiateWebRtc();
  }

  Future setRemoteData(
    Map<String, dynamic> sdp,
    var ice,
  ) async {
    // _peerConnection?.onTrack = (RTCTrackEvent event) {
    //   print('Got remote track: ${event.streams[0]}');

    //   event.streams[0].getTracks().forEach((track) {
    //     print('Add a track to the remoteStream $track');
    //     remoteStream?.addTrack(track);
    //   });
    // };
    var answer = RTCSessionDescription(
      sdp['sdp'],
      sdp['type'],
    );
    await _peerConnection?.setRemoteDescription(answer);

    for (var candidate in ice) {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        ),
      );
    }
  }

  final TextEditingController _remoteSdpController = TextEditingController();
  final TextEditingController _remoteIceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Room"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                    child: const Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        FlutterClipboard.copy(jsonEncode(_localSDP?.toMap()));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200,
                            child: Text(
                              _localSDP?.toMap().toString() ?? "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FlutterClipboard.copy(jsonEncode(_localICE));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 200,
                            child: Text(
                              _localICE.toString(),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.info_outline),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _remoteSdpController,
                  decoration: const InputDecoration(
                    hintText: "Enter Remote SDP",
                  ),
                  maxLines: 10,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _remoteIceController,
                  decoration: const InputDecoration(
                    hintText: "Enter Remote Ice",
                  ),
                  maxLines: 10,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await setRemoteData(
                  json.decode(
                    _remoteSdpController.text,
                  ),
                  json.decode(
                    _remoteIceController.text,
                  ),
                );
              },
              child: const Text(
                "Initiate the meeting",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CallRoom(
                      // onAddRemoteStream: onAddRemoteStream,
                      localStream: localStream,
                      remoteStream: remoteStream,
                    );
                  },
                ));
              },
              child: const Text("Start the meeting"),
            ),
          ],
        ),
      ),
    );
  }
}
