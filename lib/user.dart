class User {
  String _firstName;
  String _lastName;
  String _id;
  String _image;

  User(this._firstName, this._lastName, this._id, [this._image = '']);

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get id => _id;
  String get image => _image;

  User.fromFire(Map<String, dynamic> map) {
    this._firstName = map['firstName'];
    this._lastName = map['lastName'];
    this._id = map['id'];
    this._image = map['image'];
  }

  Map<String, dynamic> toFire() {
    return {
      'firstName': _firstName,
      'lastName': _lastName,
      'id': _id,
      'image': _image,
    };
  }
}
