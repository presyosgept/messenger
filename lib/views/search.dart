import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/conversation.dart';
import 'package:messenger/widget/widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// String _myName;
class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchtextEditingController =
      new TextEditingController();

  QuerySnapshot searchSnapshot;
  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                userName: searchSnapshot.docs[index]['name'],
                userEmail: searchSnapshot.docs[index]["email"],
              );
            },
          )
        : Container();
  }

  initiateSearch() {
    databaseMethods
        .getUserbyUsername(searchtextEditingController.text)
        .then((val) {
      setState(() {
        print(val);
        searchSnapshot = val;
        //print(searchSnapshot.docs.length);
      });
    });
  }

  //create Chatroom
  createChatroomAndStartConversation({String userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };
      DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomId)));
    } else {
      print("you cannot send message to yourself");
    }
  }

  Widget SearchTile({String userName, String userEmail}) {
    return Container(
        padding: EdgeInsets.all(20),
        color: Colors.black,
        child: Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                userName,
                style: simpleTextStyle(),
              ),
              Text(
                userEmail,
                style: simpleTextStyle(),
              ),
            ]),
            Spacer(),
            GestureDetector(
              onTap: () {
                createChatroomAndStartConversation(userName: userName);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30)),
                child: Text('Message'),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Search'),
        // ),
        body: SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.grey,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchtextEditingController,
                  decoration: InputDecoration(
                      hintText: 'Search Username',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearch();
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
                      child: Icon(Icons.search)),
                ),
              ],
            ),
          ),
          searchList(),
        ],
      ),
    ));
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
