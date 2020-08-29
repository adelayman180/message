import 'package:flutter/material.dart';
import './message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './message_item.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final fireStore = Firestore.instance;

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List users = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                backgroundColor: Colors.blueGrey[800],
                child: users[1].image == ''
                    ? Text(
                        users[1]
                                .firstName
                                .trim()
                                .toUpperCase()
                                .substring(0, 1) +
                            users[1]
                                .lastName
                                .trim()
                                .toUpperCase()
                                .substring(0, 1),
                        style: TextStyle(color: Colors.white),
                      )
                    : Image.network(users[1].image),
              ),
            ),
            SizedBox(width: 6),
            Flexible(
                child: Text(
              users[1].firstName + ' ' + users[1].lastName,
              maxLines: 1,
            )),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: fireStore.collection('messages').orderBy('time').snapshots(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/background.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: snapshot.hasData
                        ? ListView.builder(
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (_, i) {
                              final message = Message.fromFire(snapshot
                                  .data.documents.reversed
                                  .toList()[i]
                                  .data);

                              if ((message.sender == users[1].id &&
                                      message.receiver == users[0]) ||
                                  (message.sender == users[0] &&
                                      message.receiver == users[1].id))
                                return MessageItem(message.content,
                                    message.sender == users[0]);
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Flexible(
                          child: TextField(
                        controller: controller,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Type a message ...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          filled: true,
                          fillColor: Colors.blueGrey,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none),
                        ),
                      )),
                      SizedBox(width: 4),
                      FloatingActionButton(
                        mini: true,
                        child: Icon(Icons.send),
                        backgroundColor: Colors.blueGrey,
                        onPressed: () {
                          if (controller.text.trim() != '') {
                            final message =
                                Message(controller.text, users[0], users[1].id);
                            fireStore
                                .collection('messages')
                                .add(message.toFire());
                            controller.clear();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
