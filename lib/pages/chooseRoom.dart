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

  Future<void> _signOut() async {
    try {
      await firebaseAuth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = firebaseAuth.currentUser;
    String displayMessage = "Velkommen";
    if (user != null) {
      displayMessage = "Velkommen ${user.displayName}";
    }
    return Scaffold(
      appBar: AppBar(title: Text('Vælg et rum eller lav dit eget!')),
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
                  labelText: 'Skriv navnet på et rum',
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
              child: Text("Tilgå rum"),
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text("Log ud"),
            ),
          ],
        ),
      ),
    );
  }
}
