import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_chatapp/pages/room.dart';
import 'homepage.dart';
import 'room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class chooseRoom extends StatefulWidget {
  const chooseRoom({super.key});

  @override
  State<chooseRoom> createState() => _chooseRoomState();
}

class _chooseRoomState extends State<chooseRoom> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String displayMessage = "Welcome";
    if (user != null) {
      displayMessage = "Welcome  ${user.displayName}";
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(displayMessage),
            const TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a room name',
                labelStyle: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Room()),
                );
              },
              child: Text("Enter room"),
            ),
          ],
        ),
      ),
    );
  }
}
