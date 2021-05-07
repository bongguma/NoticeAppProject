import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:yj_noticeboardproject/Data/NoticeData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'dart:io';

Firestore firestore = Firestore.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;
List<String> _noticeImageList = <String>[];
List<NoticeImageView> _noticeImageView = <NoticeImageView>[];
NoticeData noticeData = new NoticeData();
File _image;

class CreateNoticeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 등록하기'),
      ),
      resizeToAvoidBottomInset: false,
      body: NoticeView(),
    );
  }
}

class NoticeView extends StatefulWidget {
  @override
  NoticeViewState createState() => NoticeViewState();
}

class NoticeViewState extends State<NoticeView> {
  List<String> imagePickerList = ['이미지불러오기', '사진좔영하기'];
  final noticeIDController = TextEditingController();
  final noticeTitleController = TextEditingController();
  final noticeContentController = TextEditingController();
  var now = new DateTime.now();

  @override
  void initState() {
    super.initState();

    _image = new File('');
    _noticeImageList = [];
    _noticeImageView = <NoticeImageView>[];
  }

  @override
  void dispose() {
    super.dispose();

    noticeIDController.dispose();
    noticeTitleController.dispose();
    noticeContentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: createNoticeView(context),
    );
  }

  Widget createNoticeView(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // 폼에 유니크한 글로벌 키를 생성해 자식 위젯 구별

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                child: Text("이미지 업로드"),
                onPressed: () {
                  FlutterDialog(context);
                },
              ),
              // 게시글 제목 작성자 아이디 Widget
              Text("작성자 아이디",
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: TextFormField(
                  controller: noticeIDController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '작성자 아이디',
                  ),
                  validator: (value) {
                    // 입력값이 없으면 메시지 출력
                    if (value.isEmpty) {
                      return '작성자 아이디를 입력해주세요.';
                    } else
                      return null;
                  },
                  onChanged: (value) {
                    noticeData.noticeID = value;
                  },
                ),
              ),
              // 게시글 제목 작성 Widget
              Text("제목", style: TextStyle(color: Colors.black, fontSize: 14.0)),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: TextFormField(
                  controller: noticeTitleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '제목',
                  ),
                  validator: (value) {
                    // 입력값이 없으면 메시지 출력
                    if (value.isEmpty) {
                      return '제목을 입력해주세요.';
                    } else
                      return null;
                  },
                  onChanged: (value) {
                    noticeData.title = value;
                  },
                ),
              ),
              // 게시글 내용 작성 Widget
              Text("내용", style: TextStyle(color: Colors.black, fontSize: 14.0)),
              // onSaved는 키보드로 확인 눌렀을 때엔 값이 등록되지만 빈화면을 눌러 키보드가 내려갈 시엔 값이 등록되지 않음
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: noticeContentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '내용을 입력해주세요.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        noticeData.contents = value;
                      },
                    ),
                    Container(
                        height: 400,
                        child: ListView.builder(
                          itemCount: _noticeImageView.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int i) {
                            return ListTile(
                              title: _noticeImageView[i],
                              trailing: null,
                            );
                          },
                        )),
                  ],
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: ElevatedButton(
                  onPressed: () {
                    noticeData.imageList = _noticeImageList;
                    if (formKey.currentState.validate()) {
                      firestore
                          .collection('notice')
                          .document(createNoticeNumber(false).toString())
                          .setData({
                        'noticeID': noticeData.noticeID,
                        'title': noticeData.title,
                        'contents': noticeData.contents,
                        'imageList': noticeData.imageList,
                        'date': noticeData.date,
                        'number': createNoticeNumber(false).toString(),
                        'commentData': null,
                      });
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    } else {
                      formKey.currentState.save();
                    }
                    noticeData.date = createNoticeNumber(true);
                  },
                  child: Text('등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void chooseImagePicker(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    if (image == null) return null;
    setState(() {
      _image = image;
      print('_image :: ' + _image.toString());
      // 이미지가 여러 장 일 때,
    });
    var noticeImageView = NoticeImageView(
      imageFile: _image,
    );
    _noticeImageView.insert(0, noticeImageView);
    imageUpload().then((value) => {
          print('value :: ' + value.toString()),
          _noticeImageList.add(value),
        });
  }

  Future<String> imageUpload() async {
    StorageReference storageReference = firebaseStorage.ref().child(
        "/notice/${createNoticeNumber(false)}${_noticeImageList.length}");

    StorageUploadTask storageUploadTask;
    String downloadURL;

    if (_image != null) {
      if (_image.existsSync()) {
        // 파일 업로드
        storageUploadTask = storageReference.putFile(_image);
        // 파일 업로드 완료까지 대기
        await storageUploadTask.onComplete;

        // 업로드한 사진의 URL 획득
        downloadURL = await storageReference.getDownloadURL();
      } else {
        downloadURL = null;
      }
    }
    return downloadURL;
  }

  void FlutterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Expanded(
            child: setupAlertDialoadContainer(),
          ));
        });
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 100.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: false,
        itemCount: imagePickerList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(imagePickerList[index]),
            onTap: () {
              if (index == 0) {
                chooseImagePicker(ImageSource.gallery);
              } else if (index == 1) {
                chooseImagePicker(ImageSource.camera);
              }

              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  // notice 상세보기 시, 화면 들어갈 때 고유번호가 필요하여 겹치지 않는 날짜로 지정 -
  String createNoticeNumber(bool isNoticeDate) {
    var formatter =
        new DateFormat(isNoticeDate ? 'yyyy-MM-dd HH:mm:ss' : 'yyyyMMddHHmmss');

    String formattedDate = formatter.format(now);
    return formattedDate;
  }
}

class NoticeImageView extends StatelessWidget {
  NoticeImageView({this.imageFile});
  final File imageFile;
  @override
  Widget build(BuildContext context) {
    return Image(
      width: 30,
      height: 30,
      image: (imageFile != null) ? FileImage(imageFile) : NetworkImage(""),
    );
  }
}
