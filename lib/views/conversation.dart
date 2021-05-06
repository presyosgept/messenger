import 'dart:math';
import 'package:flutter/material.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/views/chatRoomsScreen.dart';
import 'package:messenger/views/searchForGroup.dart';
import 'package:messenger/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/services/database.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String usernamee;
  ConversationScreen(this.chatRoomId,this.usernamee);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatMessagesStream;
  final picker = ImagePicker();
  String text1, imgString;

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

  Widget get ChatMessageList {
    int value=0;
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.docs[index].data()["message"] == null) {
                      // if (snapshot.data.docs[index].data()["sendBy"] ==
                      //     Constants.myName) {
                        return MessageTile(
                          snapshot.data.docs[index].data()["sendBy"],
                          null,
                          snapshot.data.docs[index].data()["sendBy"] == Constants.myName,
                          snapshot.data.docs[index].data()["url"],
                          value = 2,

                        );
                    // }
                    } else {
                      return MessageTile(
                        snapshot.data.docs[index].data()["sendBy"],
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
      "location": text1,
      "url": imgString
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
      text1 = text;
      imgString = imageString;
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
//        resizeToAvoidBottomInset: false,
// resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatRoom()))
  ), 
            title: Text("${widget.usernamee.toUpperCase()}",
                style: biggerTextStyle()),
                actions: [
                  GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SearchForGroup(chatRoomId: widget.chatRoomId)));
          //  SearchForGroup(chatRoomId: widget.chatRoomId);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.group_add, color: Colors.deepOrange[200], size: 30,)),
                  )],
                ),
                
        body: Container(
               decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/cm1.png'),
        fit: BoxFit.cover,
      )),
          child: SingleChildScrollView(child: Container(
          
              child: Column(
              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             // Container(height:70,child: ChatMessageList()),
             Container(
       height: MediaQuery.of(context).size.height /1.3,
               child: ChatMessageList),
              Container(
                
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 70,
                  color: Colors.brown[400],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                        controller: messageController,
                        decoration: InputDecoration(
                            hintText: "Aa",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none),
                      )),
                      Container(
                        height: 80,
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: TextButton(
                              child: Icon(
                                Icons.photo,
                                color: Colors.deepOrange[200],
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
                              Colors.transparent,
                              Colors.transparent,
                            ])),
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.camera_alt_rounded,
                            color: Colors.deepOrange[200],)),
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
                            width: 30,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Colors.transparent,
                              Colors.transparent,
                            ])),
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send,
                            color: Colors.deepOrange[200],)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ))),
        ));
  }
}

class MessageTile extends StatelessWidget {
  final String sender;
  final String message;
  final bool isSendByMe;
  final String record;
  final int value;
  MessageTile(this.sender,this.message, this.isSendByMe, this.record, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
    
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
         // height: 60,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isSendByMe
                      ? [
                          
                          Colors.deepPurple[400],
                          Colors.deepPurple[400],
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
              ? Container(
                child: Column(
                  children: [
                    Text(sender.toUpperCase(),
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      height: 10,
                    ),
                    Text(message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        )),
                  ],
                ),
              )
              : Column(
                children: [
                   Text(sender.toUpperCase(),
                   style: TextStyle(
                     fontSize: 20, fontWeight: FontWeight.bold
                   ),),
                   SizedBox(
                     height: 10,
                   ),
                  Container(
                      child: Image.network(record),
                    ),
                ],
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
