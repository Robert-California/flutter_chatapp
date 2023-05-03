import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';

class Room extends StatefulWidget {
  final String roomName;

  const Room({Key? key, required this.roomName}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
                        return ListTile(
                          title: Text('$user: $message'),
                        );
                      },
                    );
                }
              },
            ),
          ),
          Text("Hej" + firebaseAuth.currentUser!.displayName.toString() + "!"),
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
    if (_messageController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': _messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'user': FirebaseAuth.instance.currentUser!.displayName,
        'room': widget.roomName, // Add the room field
      });
    } catch (e) {
      print('Error adding message to Firestore: $e');
    }

    _messageController.clear();
  }

  Stream<QuerySnapshot> getMessagesStream(String roomName) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('room', isEqualTo: roomName) // Filter messages by room name
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
