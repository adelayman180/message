import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message/user.dart';
import './drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  final fireStore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = await auth.currentUser();
    if (user != null) {
      currentUser = user;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        title: Text('Message'),
      ),
      drawer: currentUser != null
          ? CustomDrawer(currentUser.uid, context)
          : Container(),
      body: FutureBuilder<QuerySnapshot>(
          future: fireStore.collection('users').getDocuments(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (_, i) {
                      final user =
                          User.fromFire(snapshot.data.documents[i].data);
                      return (user.id != currentUser.uid)
                          ? Column(
                              children: <Widget>[
                                ListTile(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/chat',
                                      arguments: [currentUser.uid, user]),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blueGrey[800],
                                      child: user.image == ''
                                          ? Text(
                                              user.firstName
                                                      .trim()
                                                      .toUpperCase()
                                                      .substring(0, 1) +
                                                  user.lastName
                                                      .trim()
                                                      .toUpperCase()
                                                      .substring(0, 1),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : Image.network(user.image),
                                    ),
                                  ),
                                  title: Text(
                                    user.firstName + ' ' + user.lastName,
                                    style: TextStyle(
                                        color: Colors.blueGrey.shade50),
                                    maxLines: 1,
                                  ),
                                ),
                                if (i != snapshot.data.documents.length - 1)
                                  Divider(
                                    color: Colors.blueGrey[400],
                                    indent: 50,
                                  ),
                              ],
                            )
                          : Container();
                    })
                : Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.blueGrey[400],
                  ));
          }),
    );
  }
}
