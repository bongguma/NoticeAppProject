import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yj_noticeboardproject/Data/CommentData.dart';
import 'package:yj_noticeboardproject/Data/NoticeData.dart';

Firestore firestore = Firestore.instance;

class NoticeDetailView extends StatelessWidget {
  final NoticeData noticeData;
  // 생성자는 NoticeData를 인자로 받습니다.
  NoticeDetailView({Key key, @required this.noticeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('게시판 상세보기'),
          actions: [
            PopupMenuButton(
                onSelected: (selectedValue) {
                  if (selectedValue.toString() == 'delete') {
                    showDeleteAlertDialog(context);
                  }
                },
                itemBuilder: (BuildContext ctx) => [
                      PopupMenuItem(child: Text('삭제'), value: 'delete'),
                      PopupMenuItem(child: Text('수정'), value: 'modify'),
                    ]),
          ],
        ),
        body: Container(
          child: DetailView(
            noticeData: noticeData,
          ),
        ));
  }

  void showDeleteAlertDialog(BuildContext context) async {
    await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: Text('삭제'),
            content: Text('삭제 하시겠습니까?'),
            actions: <Widget>[
              FlatButton(
                child: Text('취소'),
                onPressed: () {},
              ),
              FlatButton(
                child: Text('삭제'),
                onPressed: () {
                  Firestore.instance
                      .collection('notice')
                      .document(noticeData.number)
                      .delete();
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }
}

class DetailView extends StatefulWidget {
  final NoticeData noticeData;
  // 생성자는 NoticeData를 인자로 받습니다.
  DetailView({Key key, @required this.noticeData}) : super(key: key);

  @override
  NoticeDetailViewState createState() => NoticeDetailViewState();
}

class NoticeDetailViewState extends State<DetailView> {
  final List<CommentMessage> _messages = <CommentMessage>[];
  final TextEditingController userNameController = new TextEditingController();
  final TextEditingController commentController = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var _message;
    CommentData _commentData;
    if (widget.noticeData.comment != null) {
      widget.noticeData.comment.forEach((element) {
        _commentData =
            new CommentData.init(element['userName'], element['comment']);
        _message = CommentMessage(
          commenData: _commentData,
        );
        _messages.insert(0, _message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // double.infinity는 부모 길이에 맞게 100%를 채워준다.
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.noticeData.title,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  '내용',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  widget.noticeData.contents,
                  style: TextStyle(fontSize: 16.0),
                ),
                Container(
                    height: 400,
                    child: ListView.builder(
                      itemCount: widget.noticeData.imageList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int i) {
                        return ListTile(
                          title: Image(
                              width: 150,
                              height: 150,
                              image: (widget.noticeData.imageList.length > 0)
                                  ? NetworkImage(widget.noticeData.imageList[i])
                                  : NetworkImage("")),
                          trailing: null,
                        );
                      },
                    )),
                // Image(
                //     width: 150,
                //     height: 150,
                //     image: (widget.noticeData.imageList.length > 0)
                //         ? NetworkImage(widget.noticeData.imageList[0])
                //         : NetworkImage("")),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              '댓글',
              style: TextStyle(fontSize: 16),
            ),
          ),
          _messages.length > 0 ? _listData() : _noData(),
          Divider(height: 1.0),
          Container(
            child: _buildTextComposer(context),
          )
        ],
      ),
    ));
  }

  Widget _noData() {
    return Flexible(
        child: Container(
      height: 300,
      alignment: Alignment.center,
      child: Text(
        '댓글이 없습니다. 댓글을 입력해주세요.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ));
  }

  Widget _listData() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (BuildContext context, int i) => _messages[i],
        itemCount: _messages.length,
      ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey[500])),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      '작성자',
                      style: TextStyle(fontSize: 16),
                    ),
                    Flexible(
                        child: Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: TextField(
                        controller: userNameController,
                        decoration: new InputDecoration.collapsed(
                            hintText: "작성자를 입력해주세요."),
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: commentController,
                        decoration: new InputDecoration.collapsed(
                            hintText: "댓글을 입력해주세요."),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            _handleSubmitted(commentController.text);
                          }),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  void _handleSubmitted(String comment) {
    var commentData = new CommentData.init(userNameController.text, comment);
    var message = CommentMessage(
      commenData: commentData,
    );
    setState(() {
      firestore
          .collection('notice')
          .document(widget.noticeData.number)
          .updateData({
        "commentData": FieldValue.arrayUnion([
          {"userName": userNameController.text, "comment": commentData.comment},
        ])
      });
      _messages.insert(0, message);
    });
    userNameController.clear();
    commentController.clear();
  }
}

class CommentMessage extends StatelessWidget {
  CommentMessage({this.commenData});
  final CommentData commenData;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(commenData.userName,
                  style: Theme.of(context).textTheme.subhead),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(commenData.comment),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
