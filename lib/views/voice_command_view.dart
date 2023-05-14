import 'package:flutter/material.dart';

class VoiceCommandView extends StatelessWidget {
  final String command;
  final String xCoord;
  final String yCoord;
  const VoiceCommandView({Key? key, required this.command, required this.xCoord, required this.yCoord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 3, 30, 3),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.brown,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(command),
            ),
          ),
          IconButton(
            onPressed: () async {

            },
            icon: const Icon(Icons.open_in_new_outlined),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.playlist_remove_rounded)
          ),
        ],
      ),
    );
  }
}
