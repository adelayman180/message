import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final String text;
  final bool isMyMessage;
  MessageItem(this.text, this.isMyMessage);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: isMyMessage ? Colors.blueGrey[200] : Colors.blueGrey,
            borderRadius: isMyMessage
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          margin: EdgeInsets.only(
              top: 3,
              bottom: 3,
              right: isMyMessage ? 3 : MediaQuery.of(context).size.width / 3,
              left: isMyMessage ? MediaQuery.of(context).size.width / 3 : 3),
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
