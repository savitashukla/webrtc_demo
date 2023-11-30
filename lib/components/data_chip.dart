import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

Widget rtcDataChip({
  required String title,
  required String data,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Center(child: Text(data)),
          ),
          InkWell(
            onTap: () async {
              await FlutterClipboard.copy(data);
            },
            child: const Icon(Icons.copy),
          ),
        ],
      ),
    ],
  );
}
