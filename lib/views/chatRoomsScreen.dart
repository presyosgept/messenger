import 'package:flutter/material.dart';
import 'package:messenger/helper/authenticate.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/helper/helperfunctions.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/conversation.dart';
import 'package:messenger/views/search.dart';
import 'package:messenger/views/searchForGroup.dart';
import 'package:messenger/widget/widget.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream chatRoomsStream;

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return ChatRoomTile(
                    snapshot.data.docs[index]
                        .data()["chatroomId"]
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    snapshot.data.docs[index].data()["chatroomId"],
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();

    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {
      databaseMethods.getChatRooms(Constants.myName).then((result) {
        setState(() {
          chatRoomsStream = result;
        });
      });
    });
  }

  createDialog(BuildContext context) {
    TextEditingController chatId = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.brown[200],
            title: Text('Name of the Group'),
            content: TextField(
              
              cursorColor: Colors.black,
              controller: chatId,
              decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.brown[400],
                  // elevation: 5.0,
                  child: Text('OKAY'),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchForGroup(chatRoomId: chatId.text)));
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red[700],
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Text('Messages'),
        ),
        actions: [
            GestureDetector(
              onTap: () {
                createDialog(context);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.group_add, size: 28,))),
          GestureDetector(
              onTap: () {
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.brown[200],
                    content: Text("Are you sure you want to log out?",
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                    ),),
                    actions: <Widget>[
                      FlatButton(
                        minWidth: 12,
                        color: Colors.brown[400],
                        onPressed: () {
                          authMethods.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Authenticate()));
                        },
                        child: Text("YES"),
                      ),
                      FlatButton(
                        minWidth: 12,
                        color: Colors.brown[400],
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          
                        },
                        child: Text("NO"),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app))),
        
          // Container(
          //     width: 95,
          //     height: 30,
          //     child: Center(child: 
          //    // Text(Constants.myName.toUpperCase())
          //      Text("${Constants.myName.toUpperCase()}",
          //     )))
        ],
      ),
      body: 
      Container(
          decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/cm2.png'),
        fit: BoxFit.cover,
      )),
        child: ChatRoomList()),
      floatingActionButton: Container(
        child: FloatingActionButton(
          backgroundColor: Colors.deepOrange[200],
          child: Icon(Icons.add,color: Colors.black,),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          },
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  ChatRoomTile(this.userName, this.chatRoomId);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(chatRoomId,userName)));
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.deepOrange[200],
                      borderRadius: BorderRadius.circular(40)),
                  child: Text("${userName.substring(0, 1).toUpperCase()}",
                      style: biggerTextStyle())),
              SizedBox(width: 8),
              Text(
                userName,
                style: biggerTextStyle(),
              )
            ],
          )),
    );
  }
}
