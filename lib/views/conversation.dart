import 'dart:math';
import 'package:flutter/material.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final picker = ImagePicker();
  String one, two;

  Widget _buildBody(BuildContext context, bool name) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc()
          .collection('chats')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs, name);
      },
    );
  }

  Widget _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot, bool name) {
    return ListView(
        padding: const EdgeInsets.only(top: 50.0),
        children: snapshot
            .map((data) => buildListItem(context, data, name))
            .toList());
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data, bool name) {
    final record = Record.fromSnapshot(data);
    int value;
    return Padding(
      key: ValueKey(record.location),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget ChatMessageList() {
    int value;
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.docs[index].data()["message"] == null) {
                      if (snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName) {
                        return MessageTile(
                          null,
                          true,
                          snapshot.data.docs[index].data()["url"],
                          value = 2,
                        );
                      }
                    } else {
                      return MessageTile(
                        snapshot.data.docs[index].data()["message"],
                        snapshot.data.docs[index].data()["sendBy"] ==
                            Constants.myName,
                        snapshot.data.docs[index].data()["url"],
                        value = 1,
                      );
                    }
                  },
                )
              : Container();
        });
  }

  sendMessage() {
    Map<String, dynamic> messageMap = {
      "message": messageController.text,
      "sendBy": Constants.myName,
      "time": DateTime.now().millisecondsSinceEpoch,
      "location": one,
      "url": two
    };
    databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
    messageController.text = "";
  }

  Future pickImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.camera);

    _uploadImageToFirebase(File(pickedFile.path));
  }

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    _uploadImageToFirebase(File(image.path));
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      int randomNumber = Random().nextInt(100000);
      String imageLocation = 'images/image${randomNumber}.jpg';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(imageLocation);
      final UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask;
      _addPathToDatabase(imageLocation);
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> _addPathToDatabase(String text) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(text);
      var imageString = await ref.getDownloadURL();
      Map<String, dynamic> messageMap = {
        "message": null,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "location": text,
        "url": imageString
      };
      await databaseMethods.addConversationMessages(
          widget.chatRoomId, messageMap);
      one = text;
      two = imageString;
    } catch (e) {
      print(e.message);
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
        appBar: AppBar(
            title: Text("${Constants.myName.toUpperCase()}",
                style: biggerTextStyle())),
        body: Container(
            child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
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
                              Icons.photo_album,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              getImage();
                            }),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImage();
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
                          child: Icon(Icons.camera_alt)),
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
  final String message;
  final bool isSendByMe;
  final String record;
  final int value;
  MessageTile(this.message, this.isSendByMe, this.record, this.value);

  @override
  Widget build(BuildContext context) {
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
          child: value == 1
              ? Text(message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ))
              : Container(
                  child: Image.network(record),
                )),
    );
  }
}

class Record {
  final String location;
  final String url;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        location = map['location'],
        url = map['url'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$url>";
}
