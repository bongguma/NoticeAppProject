import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yj_noticeboardproject/NoticeJoinView.dart';
import 'package:yj_noticeboardproject/showNoticeListView.dart';

class NoticeLoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      resizeToAvoidBottomInset: false,
      body: LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("이메일",
                      style: TextStyle(color: Colors.black, fontSize: 14.0)),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: '이메일'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "이메일을 입력해주세요";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("비밀번호",
                      style: TextStyle(color: Colors.black, fontSize: 14.0)),
                  TextFormField(
                    obscureText: true, // 비밀번호를 적을때 안보이도록
                    controller: _passwordController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: '비밀번호'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "비밀번호를 입력해주세요";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    ElevatedButton(
                      child: Text('회원가입'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoticeJoinView()));
                      },
                    ),
                    ElevatedButton(
                      child: Text('로그인'),
                      onPressed: () {
                        _login();
                      },
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _login() async {
    try {
      final newUser = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      if (newUser != null) {
        // 로그인 성공
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShowNoticeListView()));
      } else {}
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
