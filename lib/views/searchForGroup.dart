import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/constants.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/conversation.dart';
import 'package:messenger/widget/widget.dart';

class SearchForGroup extends StatefulWidget {
  final String chatRoomId;
  SearchForGroup({this.chatRoomId});
  @override
  _SearchForGroupState createState() => _SearchForGroupState();
}

class _SearchForGroupState extends State<SearchForGroup> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchtextEditingController =
      new TextEditingController();
  int flag = 0;
  String chatRoomIdFinal;
  List<String> users = [];



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
      });
    });
  }

  createChatroomAndStartConversation({String userName}) {
  
    if (userName != Constants.myName) {
      String chatRoomIdFinal = widget.chatRoomId;
      if (users.length == 0) {
        users.add(Constants.myName);
        users.add(userName);
        print('added successfully');
      } else {
        users.add(userName);
        print('added the other successfully ');
      }
    } else {
      print("you cannot send message to yourself");
    }
    return Container();
  }

  createChatroom() {
    print(chatRoomIdFinal);
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatroomId": widget.chatRoomId
    };
    
    DatabaseMethods().createChatRoom(widget.chatRoomId, chatRoomMap);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(widget.chatRoomId,widget.chatRoomId)));
  }

  Widget SearchTile({String userName, String userEmail}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
          color: Colors.transparent,
        child: Column(
          children: [
            Row(
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
                  
                     return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.brown[200],
                    title: Text("GROUPCHAT"),
                    content: Text("Are you sure you want to add this person?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                    actions: <Widget>[
                      FlatButton(
                        minWidth: 12,
                        color: Colors.brown[400],
                        onPressed: () {
                        createChatroomAndStartConversation(userName: userName);
                        searchtextEditingController.text="";
                        searchSnapshot=null;
                        searchList();
                        setState(() {
                          
                        });
                        Navigator.of(ctx).pop();
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
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text('Add',
                    style: TextStyle(
                      color: Colors.black
                    ),),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                )
              ],
            ),
          ],
        )
        );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search For Group'),
            backgroundColor: Colors.brown[300],
        ),
        body: Container(
                 decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/images/cm2.png'),
            fit: BoxFit.cover,
          )),
          child: Column(
            children: [
              Container(
               color: Colors.brown[300],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          cursorColor: Colors.black,
                      controller: searchtextEditingController,
                      decoration: InputDecoration(
                          hintText: 'Search Username',
                          hintStyle: TextStyle(
                              color: Colors.black, fontStyle: FontStyle.italic),
                          border: InputBorder.none),
                    )),
                    GestureDetector(
                      onTap: () {
                        initiateSearch();

                        // setState(() {
                        //    initiateSearch();
                        // });
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
                          child: Icon(Icons.search)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              searchList(),
               SizedBox(
                height: 20,
              ),
              Container(
                child: GestureDetector(
                  onTap: () {
                    flag = 1;
                    createChatroom();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                          color: Colors.deepOrange[200],
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 16,),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
