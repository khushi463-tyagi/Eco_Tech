import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //Sign out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'LOGGED IN ' + user.email!,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
