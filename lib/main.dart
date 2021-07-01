import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yj_noticeboardproject/NoticeLoginView.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // StatelessWidget : 상태가 없는 위젯

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // home: ShowNoticeListView(),
      home: NoticeLoginView(),
    );
  }
}
