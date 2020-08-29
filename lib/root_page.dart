import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = await FirebaseAuth.instance.currentUser();
    Navigator.pushReplacementNamed(context, user == null ? '/login' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[100],
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
