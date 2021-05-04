import 'dart:io';

class NoticeData {
  String _noticeId;
  String _title;
  String _contents;
  String _number;
  List<String> _imageUrlList;
  String _date;
  List<dynamic> _comment;

  String get noticeID => _noticeId;
  set noticeID(String noticeID) => this._noticeId = noticeID;

  String get title => _title;
  set title(String title) => this._title = title;

  String get contents => _contents;
  set contents(String contents) => this._contents = contents;

  String get number => _number;
  set number(String number) => this._number = number;

  List<String> get imageList => _imageUrlList;
  set imageList(List<String> image) => this._imageUrlList = image;

  String get date => _date;
  set date(String date) => this._date = date;

  List<dynamic> get comment => _comment;
  set comment(List<dynamic> comment) => this._comment = comment;

  NoticeData setNoticeData(Map<String, dynamic> value) {
    title = value['title'].toString();
    contents = value['contents'].toString();
    imageList = value['imageList']?.cast<String>();
    date = value['date'].toString();
    number = value['number'].toString();
    comment = value['commentData'];
  }
}
