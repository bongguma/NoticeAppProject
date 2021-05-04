import 'dart:io';

class CommentData {
  String _userName;
  String _comment;

  String get userName => _userName;
  set userName(String userName) => this._userName = userName;

  String get comment => _comment;
  set comment(String comment) => this._comment = comment;

  CommentData() {}

  CommentData.init(String userName, String comment) {
    this.userName = userName;
    this.comment = comment;
  }
}
