import 'package:flutter/material.dart';


import '../create_room.dart';
import '../join_room.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const JoinRoom(
                    // peerConnection: _peerConnection,
                    );
              },
            ));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Join Room"),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return CreateRoom(
                    // peerConnection: _peerConnection,
                    );
              },
            ));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Create Room"),
          ),
        )
      ],
    );
  }
}
