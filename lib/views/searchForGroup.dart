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
      int flag=0;
      String chatRoomIdFinal;
      List<String> users =[];
      
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
        : Container(color: Colors.pink, child: Text('Taler'));
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

   if(userName != Constants.myName){
      String chatRoomIdFinal=widget.chatRoomId;
    if(users.length==0){
      users.add(Constants.myName);
      users.add(userName);
      print('added successfully');
    }
    else
    {
      users.add(userName);
      print('added the other successfully ');
    }
   }
   else{
     print("you cannot send message to yourself");
   }
  }
  createChatroom()
  {
    print(chatRoomIdFinal);
     Map<String, dynamic> chatRoomMap ={ "users":users,"chatroomId":widget.chatRoomId};
    DatabaseMethods().createChatRoom(widget.chatRoomId,chatRoomMap);
     Navigator.push(context, MaterialPageRoute(builder: (context)=> ConversationScreen(widget.chatRoomId)));

  }

Widget SearchTile({String userName,String userEmail}){
   return Container(
      padding: EdgeInsets.all(20),
        color: Colors.black,
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
                  onTap: (){
                    createChatroomAndStartConversation(userName: userName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text('Add'),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                )
              ],
            ),
            
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
        appBar: AppBar(
          title: Text('Search For Group'),
        ),
        body: Container(
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
                        hintText: 'search username',
                        hintStyle: TextStyle(color: Colors.white54),
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
            Container(
              child:
                GestureDetector(
                    onTap: () {
                      flag=1;
                      createChatroom();
                    },
                    child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text('Done'),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  ),
            )
          ],
          
        ),
        
        ));
  }
}


