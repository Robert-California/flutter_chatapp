import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'homepage.dart';
import 'package:image_picker/image_picker.dart';

class Room extends StatefulWidget {
  final String roomName;

  const Room({Key? key, required this.roomName}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: getMessagesStream(widget.roomName),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final messageDoc = snapshot.data!.docs[index];
                      final message = messageDoc['text'];
                      final user = messageDoc['user'];
                      if (messageDoc['imageUrl'] != null) {
                        final imageUrl = messageDoc['imageUrl'];
                        return ListTile(
                          title: Text('$user: $message'),
                          subtitle: Image.network(imageUrl),
                        );
                      }
                      return ListTile(
                        title: Text('$user: $message'),
                      );
                    },
                  );
              }
            },
          )),
          _imageFile != null ? Image.file(_imageFile!) : SizedBox(),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Tilføj billede'),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Skriv en besked!',
              labelStyle: TextStyle(fontSize: 20),
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _imageFile == null) return;

    try {
      String? imageUrl;

      if (_imageFile != null) {
        final firebaseStorageRef =
            FirebaseStorage.instance.ref().child(DateTime.now().toString());
        final uploadTask = firebaseStorageRef.putFile(_imageFile!);
        final snapshot = await uploadTask.whenComplete(() {});

        if (snapshot.state == TaskState.success) {
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          print('Image upload task did not complete successfully');
        }
      }

      await FirebaseFirestore.instance.collection('messages').add({
        'text': _messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'user': FirebaseAuth.instance.currentUser!.displayName,
        'room': widget.roomName,
        'imageUrl': imageUrl,
      });
    } catch (e) {
      print('Error adding message to Firestore: $e');
    }

    _messageController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Stream<QuerySnapshot> getMessagesStream(String roomName) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('room', isEqualTo: roomName) // Filter messages by room name
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
