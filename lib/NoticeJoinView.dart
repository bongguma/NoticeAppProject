import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoticeJoinView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      resizeToAvoidBottomInset: false,
      body: JoinView(),
    );
  }
}

class JoinView extends StatefulWidget {
  @override
  JoinViewState createState() => JoinViewState();
}

class JoinViewState extends State<JoinView> {
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
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: "회원가입할 이메일을 입력해주세요",
                  border: OutlineInputBorder(),
                  hintText: 'E-mail'),
              validator: (String value) {
                if (value.isEmpty) {
                  return "이메일을 입력해주세요";
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: true, // 비밀번호를 적을때 안보이도록
              controller: _passwordController,
              decoration: InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  labelText: "회원가입할 비밀번호를 입력해주세요",
                  border: OutlineInputBorder(),
                  hintText: 'password'),
              validator: (String value) {
                if (value.isEmpty) {
                  return "비밀번호를 입력해주세요";
                }
                return null;
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _register();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => MyApp()));
                },
                child: Text('회원가입'),
              ),
            )
          ],
        ),
      ),
    );
  }

  //회원가입 하는 메소드
  void _register() async {
    final AuthResult result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
    final FirebaseUser user = result.user;

    if (user == null) {
      final snacBar = SnackBar(
        content: Text("Please try again later"),
      );
      Scaffold.of(context).showSnackBar(snacBar);
    }
  }
}
