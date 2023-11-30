import 'package:flutter/material.dart';

import 'data_chip.dart';

Future<dynamic> showJoinPopUp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: SizedBox(
              height: 300,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    rtcDataChip(
                      data: "SDP packet",
                      title: "SDP Data",
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    rtcDataChip(
                      data: "ICE Data",
                      title: "ICE Data",
                    ),
                  ],
                ),
              )));
    },
  );
}
