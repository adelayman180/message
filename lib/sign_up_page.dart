import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:message/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

String firstName, lastName;

class _SignUpPageState extends State<SignUpPage> {
  bool obscure = true, loading = false;
  final auth = FirebaseAuth.instance;
  final fireStore = Firestore.instance;
  final key = GlobalKey<FormState>();
  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.longestSide,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg1.jpg'), fit: BoxFit.cover),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/message.png',
                    filterQuality: FilterQuality.high,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: <Widget>[
                      NameTextField('First name'),
                      SizedBox(width: 10),
                      NameTextField('last name'),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator: (val) => val.trim().length < 10
                        ? 'Enter a valid email address!'
                        : null,
                    onSaved: (txt) => email = txt,
                    cursorColor: Colors.blueGrey,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(color: Colors.redAccent[100]),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.blueGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'E-mail address',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black45,
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (val) => val.trim().length < 6
                        ? 'Password must be 6 charactar at least.'
                        : null,
                    onSaved: (txt) => password = txt,
                    cursorColor: Colors.blueGrey,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(color: Colors.redAccent[100]),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.blueGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black45,
                      suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          }),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: obscure,
                  ),
                  SizedBox(height: 25),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.blueGrey,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    onPressed: () => signUp(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp() async {
    key.currentState.save();
    if (key.currentState.validate()) {
      setState(() {
        loading = true;
      });
      try {
        final user = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          final signed = User(firstName, lastName, user.user.uid);
          await fireStore
              .collection('users')
              .document(signed.id)
              .setData(signed.toFire());
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          showError('This email already in use, Enter anthor one.');
        } else if (e.code == 'ERROR_INVALID_EMAIL') {
          showError('This \'s invalid email address, Enter a valid one.');
        } else {
          showError('ERROR !!');
        }
      }
      setState(() {
        loading = false;
      });
    }
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
}

class NameTextField extends StatelessWidget {
  final String hint;
  NameTextField(this.hint);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        onSaved: (txt) =>
            hint == 'First name' ? firstName = txt : lastName = txt,
        validator: (val) => val.trim().length < 3 ? 'Enter $hint' : null,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent[100]),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black45,
        ),
        maxLength: 15,
        cursorColor: Colors.blueGrey,
      ),
    );
  }
}
