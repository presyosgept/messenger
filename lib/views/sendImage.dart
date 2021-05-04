import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'dart:math';

class SendImage extends StatefulWidget {
  @override
  SendImageState createState() => SendImageState();
}

class SendImageState extends State<SendImage> {
  final picker = ImagePicker();
  File imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pekshur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              child: _buildBody(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                    size: 30,
                  ),
                  onPressed: () {
                    pickImage();
                  },
                ),
                RaisedButton(
                  child: Icon(
                    Icons.photo_album,
                    color: Colors.blue,
                    size: 30,
                  ),
                  onPressed: () {
                    getImage();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('storage').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
        padding: const EdgeInsets.only(top: 50.0),
        children:
            snapshot.map((data) => buildListItem(context, data)).toList());
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.location),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "chuchu" + record.location,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Image.network(record.url),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    _uploadImageToFirebase(File(image.path));
  }

  Future pickImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.camera);

    // setState(() {
    //   imageFile = File(pickedFile.path);
    // });

    _uploadImageToFirebase(File(pickedFile.path));
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

  Future<void> _addPathToDatabase(String imageLocation) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imageLocation);
      var imageString = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc()
          .set({'url': imageString, 'location': imageLocation});
    } catch (e) {
      print(e.message);
    }
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
