import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email, password;
  bool obscure = true, loading = false;
  final auth = FirebaseAuth.instance;
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.longestSide,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
            ),
            child: Form(
              key: key,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'images/message.png',
                          filterQuality: FilterQuality.high,
                          width: MediaQuery.of(context).size.width / 2,
                        ),
                        SizedBox(height: 40),
                        TextFormField(
                          validator: (val) => val.trim().length < 10
                              ? 'Enter a valid email address!'
                              : null,
                          onSaved: (txt) => email = txt,
                          cursorColor: Colors.blueGrey,
                          decoration: InputDecoration(
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
                            'Log in',
                            style: TextStyle(fontSize: 16),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          onPressed: () => login(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Divider(
                        height: 15,
                        indent: 70,
                        endIndent: 70,
                        color: Color(0xff777777),
                      ),
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/sign'),
                        child: Text(
                          'New here?!   Sign Up',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    key.currentState.save();
    if (key.currentState.validate()) {
      setState(() {
        loading = true;
      });
      try {
        final user = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        if (e.code == 'ERROR_INVALID_EMAIL') {
          showError('This \'s invalid email address, Enter a valid one.');
        } else if (e.code == 'ERROR_WRONG_PASSWORD') {
          showError('Password is wrong.');
        } else if (e.code == 'ERROR_USER_NOT_FOUND') {
          showError('Email address not found!');
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
