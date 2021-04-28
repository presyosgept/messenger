import 'package:flutter/material.dart';
import 'package:messenger/widget/widget.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
          body: Container(
        child: Text("mao nani dzai chat chat na diri og unsa oa diha"),
      ),
    );
  }
}
