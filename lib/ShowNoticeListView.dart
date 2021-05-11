import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yj_noticeboardproject/ChartExampleView.dart';
import 'package:yj_noticeboardproject/CreateNoticeView.dart';
import 'package:yj_noticeboardproject/NoticeDetailView.dart';
import 'package:yj_noticeboardproject/Data/NoticeData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yj_noticeboardproject/NoticeLoginView.dart';

List<NoticeData> noticeDataList = []; // 전역으로 noticeDataList 가져오기
var refreshKey = GlobalKey<RefreshIndicatorState>();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
Firestore firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;

// 제일 겉면은 변경 가능 상태가 필요하지 않은 widget
class ShowNoticeListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 뒤로 가기 제어를 위한 widget
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, //backBtn hide 처리
          title: Text('게시판'),
        ),
        body: NoticeListView(),
      ),
    );
  }
}

class NoticeListView extends StatefulWidget {
  @override
  NoticeListViewState createState() => NoticeListViewState();
}

class NoticeListViewState extends State<NoticeListView> {
  @override
  void initState() {
    super.initState();

    _FirebaseCloudMessagingListeners();
    refreshList();
  }

  void _FirebaseCloudMessagingListeners() {
    // firebase FCM 디바이스 Token 값
    _firebaseMessaging.getToken().then((token) {
      print('token:' + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        // ListView 크기에 맞게 동적으로 공간차지를 도와줌
        Expanded(child: showNoticeListView()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('게시글 추가'),
              onPressed: () {
                // createNoticeView에서 돌아오면 listView 데이터를 refresh 해줌.
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateNoticeView()))
                    .then((value) => {
                          refreshList(),
                        });
              },
            ),
            ElevatedButton(
              child: Text('차트 예제'),
              onPressed: () {
                // chart 라이브러리 사용해서 예제 진행-
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChartExampleView()));
              },
            ),
            ElevatedButton(
              child: Text('로그아웃'),
              onPressed: () {
                _auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NoticeLoginView()),
                    (route) => false);
              },
            ),
          ],
        )
      ],
    ));
  }

  Widget showNoticeListView() {
    return RefreshIndicator(
        key: refreshKey,
        child: ListView.separated(
          itemCount: noticeDataList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int i) {
            return ListTile(
              title: ListTitleView(noticeDataList[i]),
              trailing: null,
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NoticeDetailView(
                            noticeData: noticeDataList[i]))).then((value) => {
                      refreshList(),
                    })
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
        onRefresh: refreshList);
  }

  //async wait 을 쓰기 위해서는 Future 타입을 이용함
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 0)); //thread sleep 같은 역할을 함.
    //새로운 정보를 그려내는 곳
    setState(() {
      noticeDataList = []; // firebase 안에 있는 데이터를 중복된 값으로 가져오지 않게 하기 위해서 초기화
      getCollection(firestore).then((value) {
        setState(() {
          value.forEach((element) {
            NoticeData noticeData = new NoticeData();
            noticeData.setNoticeData(element);
            noticeDataList.add(noticeData);
          });
        });
      });
    });
    return null;
  }

  Widget ListTitleView(NoticeData noticeData) {
    return Center(
      child: Row(
        children: [
          Container(
            color: (noticeData.imageList[0].isEmpty) ? Colors.grey[200] : null,
            child: Image(
                width: 50,
                height: 50,
                image: (noticeData.imageList.length > 0)
                    ? NetworkImage(noticeData.imageList[0])
                    : NetworkImage("")),
          ),
          Container(
            margin: EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  noticeData.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                Text(
                  noticeData.date != null ? noticeData.date : " ",
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 컬렉션 전체 데이터 가져오기 및 컬렉션 제목 list add
Future<List<Map<String, dynamic>>> getCollection(Firestore firestore) async {
  List<Map<String, dynamic>> list;
  QuerySnapshot collectionSnapshot =
      await firestore.collection("notice").getDocuments();

  list = collectionSnapshot.documents.map((DocumentSnapshot docSnapshot) {
    return docSnapshot.data;
  }).toList();
  return list;
}
