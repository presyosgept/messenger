import 'package:flutter/material.dart';
import 'package:messenger/helper/authenticate.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/views/search.dart';
import 'package:messenger/widget/widget.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          GestureDetector(
              onTap: () {
                authMethods.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Authenticate()));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.search),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));
        },
      ),
      body: Container(
        child: Text("mao nani dzai chat chat na diri og unsa oa diha"),
      ),
    );
  }
}
