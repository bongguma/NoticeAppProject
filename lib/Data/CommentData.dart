import 'dart:io';

class CommentData {
  String _userName;
  String _comment;
  String _date;

  String get userName => _userName;
  set userName(String userName) => this._userName = userName;

  String get comment => _comment;
  set comment(String comment) => this._comment = comment;

  String get date => _date;
  set date(String date) => this._date = date;

  CommentData() {}

  CommentData.init(String userName, String comment, String date) {
    this.userName = userName;
    this.comment = comment;
    this.date = date;
  }
}
