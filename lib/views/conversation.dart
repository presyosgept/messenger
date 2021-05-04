import 'package:flutter/material.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/views/sendImage.dart';
import 'package:messenger/widget/widget.dart';
import 'package:messenger/services/database.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatMessagesStream;

  Widget ChatMessageList() {
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      snapshot.data.docs[index].data()["message"],
                      snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName,
                    );
                  },
                )
              : Container();
        });
  }

// DatabaseMethods databaseMethods = new DatabaseMethods();
  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "location": "precious",
        "url": "gift"
      };
      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
      messageController.text = "";
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((result) {
      setState(() {
        chatMessagesStream = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title:Text("${widget.userName.toUpperCase()}",
        //               style: biggerTextStyle())),
        appBar: AppBar(
            title: Text("${widget.chatRoomId.toUpperCase()}",
                style: biggerTextStyle())),
        body: Container(
            child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                          hintText: 'Aa',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none),
                    )),
                    Container(
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: TextButton(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SendImage()));
                            }),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            const Color(0x36FFFFFF),
                            const Color(0x0FFFFFFF),
                          ])),
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.send)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )));
  }
}

class MessageTile extends StatelessWidget {
  // builder: (BuildContext context, AsyncSnapshot snapshot)
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);
  @override
  Widget build(BuildContext context) {
    //final record = Record.fromSnapshot(snapshot.data);
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isSendByMe
                      ? [
                          const Color(0xff007EF4),
                          const Color(0xff2A75BC),
                        ]
                      : [
                          const Color(0x1AFFFFFF),
                          const Color(0x1AFFFFFF),
                        ]),
              borderRadius: isSendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23),
                    )),
          child: message == null
              ? Text("null",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ))
              : Text(message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ))),
    );
  }
}
