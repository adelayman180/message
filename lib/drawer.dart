import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './user.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class CustomDrawer extends StatefulWidget {
  final String userDataId;
  final BuildContext cxt;
  CustomDrawer(this.userDataId, this.cxt);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String firstName;
  String lastName;
  final auth = FirebaseAuth.instance;
  final fireStore = Firestore.instance;
  FirebaseUser firebaseUser;
  File _image;
  String _uploadedFileURL;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final userData =
        await fireStore.collection('users').document(widget.userDataId).get();
    firstName = userData.data['firstName'];
    lastName = userData.data['lastName'];
    _uploadedFileURL = userData.data['image'];
    firebaseUser = await auth.currentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      width: MediaQuery.of(context).size.width * 3 / 4,
      color: Colors.blueGrey[300],
      child: firstName != null
          ? ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey[800],
                        child: _uploadedFileURL == ''
                            ? Text(
                                firstName.trim().toUpperCase().substring(0, 1) +
                                    lastName
                                        .trim()
                                        .toUpperCase()
                                        .substring(0, 1),
                                style: TextStyle(color: Colors.white),
                              )
                            : Image.network(_uploadedFileURL),
                      ),
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        firstName + ' ' + lastName,
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                Divider(),
                ListTile(
                  title: Text('Edit my name'),
                  trailing: Icon(Icons.edit),
                  onTap: () => editName(),
                ),
                Divider(height: 0, endIndent: 50, indent: 50),
                ListTile(
                  title: Text('Change my photo'),
                  trailing: Icon(Icons.photo_library),
                  onTap: () => chooseFile(),
                ),
                Divider(height: 0, endIndent: 50, indent: 50),
                ListTile(
                  title: Text('Change my password'),
                  trailing: Icon(Icons.vpn_key),
                  onTap: () => changePassword(),
                ),
                Divider(height: 0, endIndent: 50, indent: 50),
                ListTile(
                  title: Text('Delete my account'),
                  trailing: Icon(Icons.delete_forever),
                  onTap: () => deleteUser(),
                ),
                Divider(height: 0, endIndent: 50, indent: 50),
                ListTile(
                  title: Text('Sign Out'),
                  trailing: Icon(Icons.exit_to_app),
                  onTap: () => auth.signOut().then(
                      (_) => Navigator.pushReplacementNamed(context, '/login')),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery)
        .then((image) => _image = image);
    await uploadFile();
  }

  Future uploadFile() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) {
      fireStore.collection('users').document(firebaseUser.uid).setData(
          User(firstName, lastName, firebaseUser.uid, fileURL).toFire());
      Navigator.pop(context);
    });
  }

  void showError(String txt) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(txt),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  textColor: Theme.of(context).primaryColor,
                  child: Text('OK'),
                ),
              ],
            ));
  }

  void deleteUser() async {
    final id = firebaseUser.uid;
    try {
      await firebaseUser.delete();
      await fireStore.collection('users').document(id).delete();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showError('Error!');
    }
  }

  void editName() async {
    String fName, lName;
    User user;
    final key = GlobalKey<FormState>();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => FutureBuilder<DocumentSnapshot>(
            future:
                fireStore.collection('users').document(firebaseUser.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) user = User.fromFire(snapshot.data.data);
              return Container(
                color: Colors.blueGrey[200],
                padding: EdgeInsets.fromLTRB(30, 20, 30,
                    MediaQuery.of(widget.cxt).viewInsets.bottom + 20),
                child: snapshot.hasData
                    ? Form(
                        key: key,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              initialValue: user.firstName,
                              onSaved: (txt) => fName = txt,
                              validator: (txt) => txt.trim().length < 3
                                  ? 'Enter First Name!'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              initialValue: user.lastName,
                              onSaved: (txt) => lName = txt,
                              validator: (txt) => txt.trim().length < 3
                                  ? 'Enter last Name!'
                                  : null,
                            ),
                            SizedBox(height: 20),
                            FlatButton(
                              child: Text('Change'),
                              onPressed: () {
                                key.currentState.save();
                                if (key.currentState.validate()) {
                                  fireStore
                                      .collection('users')
                                      .document(user.id)
                                      .setData({
                                    'id': firebaseUser.uid,
                                    'firstName': fName,
                                    'lastName': lName,
                                    'image': _uploadedFileURL != ''
                                        ? _uploadedFileURL
                                        : '',
                                  }).then((_) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                }
                              },
                            )
                          ],
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        height: 180,
                        child: CircularProgressIndicator(),
                      ),
              );
            }));
  }

  void changePassword() {
    String password;
    final key = GlobalKey<FormState>();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              color: Colors.blueGrey[200],
              padding: EdgeInsets.fromLTRB(
                  30, 20, 30, MediaQuery.of(widget.cxt).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Form(
                    key: key,
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'New Password'),
                      obscureText: true,
                      onSaved: (txt) => password = txt,
                      validator: (txt) =>
                          password.length < 6 ? 'Password is weak' : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  FlatButton(
                    child: Text('Change'),
                    onPressed: () {
                      key.currentState.save();
                      if (key.currentState.validate()) {
                        try {
                          firebaseUser
                              .updatePassword(password)
                              .then((_) => Navigator.pop(context));
                        } catch (e) {
                          showError('Error!');
                        }
                      }
                    },
                  )
                ],
              ),
            ));
  }
}
