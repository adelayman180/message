import 'package:flutter/material.dart';
import './login_page.dart';
import './sign_up_page.dart';
import './chat_page.dart';
import './home_page.dart';
import './root_page.dart';

main(List<String> args) {
  runApp(MaterialApp(
    theme:
        ThemeData(primaryColor: Colors.blueGrey, accentColor: Colors.blueGrey),
    routes: {
      '/login': (_) => LoginPage(),
      '/sign': (_) => SignUpPage(),
      '/chat': (_) => ChatPage(),
      '/home': (_) => HomePage(),
      '/': (_) => RootPage(),
    },
  ));
}
