import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room.dart';
import 'homepage.dart';

class ChooseRoom extends StatefulWidget {
  const ChooseRoom({Key? key}) : super(key: key);

  @override
  _ChooseRoomState createState() => _ChooseRoomState();
}

class _ChooseRoomState extends State<ChooseRoom> {
  final TextEditingController _roomController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = firebaseAuth.currentUser;
    String displayMessage = "Welcome";
    if (user != null) {
      displayMessage = "Welcome ${user.displayName}";
    }
    return Scaffold(
      appBar: AppBar(title: Text('Choose a room')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(displayMessage),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _roomController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a room name',
                  labelStyle: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_roomController.text.trim().isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Room(roomName: _roomController.text.trim()),
                    ),
                  );
                }
              },
              child: Text("Enter room"),
            ),
          ],
        ),
      ),
    );
  }
}
