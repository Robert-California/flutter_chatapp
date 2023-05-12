import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'chooseRoom.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    await googleSignIn.signOut();
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // If the user cancels the sign-in flow, googleUser will be null
    if (googleUser == null) return null;

    // Obtain the authentication details from the Google Sign-In provider
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase using the Google access token
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    return await firebaseAuth.signInWithCredential(credential);
  }

  Future<void> _signOut() async {
    try {
      await googleSignIn.signOut();
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
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In with Firebase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SignInButton(
              Buttons.Google,
              onPressed: () async {
                UserCredential? user = await signInWithGoogle();
                if (user != null) {
                  print('User signed in: ${user.user?.displayName}');
                  // Navigate to another screen or update the UI as needed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ChooseRoom(); // Navigate to ChooseRoom widget
                      },
                    ),
                  );
                } else {
                  print('User cancelled the sign-in flow');
                }
              },
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
