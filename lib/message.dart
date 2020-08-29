class Message {
  String _content;
  String _sender;
  String _receiver;
  final _time = DateTime.now();

  Message(this._content, this._sender, this._receiver);

  String get content => _content;
  String get sender => _sender;
  String get receiver => _receiver;

  Message.fromFire(Map<String, dynamic> map) {
    _content = map['content'];
    _sender = map['sender'];
    _receiver = map['receiver'];
  }

  Map<String, dynamic> toFire() {
    return {
      'content': _content,
      'sender': _sender,
      'receiver': _receiver,
      'time': _time,
    };
  }
}
