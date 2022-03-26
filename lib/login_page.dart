import 'package:ask_it/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
  FocusNode textEmailFocus = FocusNode();
  FocusNode textPasswordFocus = FocusNode();
}

class _LoginPageState extends State<LoginPage> {
  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //배경 누르면 포커스 해제
      onTap: () {
        widget.textEmailFocus.unfocus();
        widget.textPasswordFocus.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromARGB(255, 29, 30, 37),
          body: SafeArea(
            //전체 박스 감싸는 div---------------------------------------
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 4),
                  //Ask It 로고 박스---------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: const Text(
                        "AskIT",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                  //sign in 글 박스-------------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: const Text(
                        "Sign in to ask a question",
                        style: TextStyle(
                          color: Color.fromARGB(128, 255, 255, 255),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 2),
                  //Email Pw 인풋 창---------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: Column(children: [
                        TextFormField(
                          //이메일 텍스트박스------------------------------
                          controller: emailInputController,
                          focusNode: widget.textEmailFocus,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(128, 255, 255, 255),
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 7),
                        TextFormField(
                          //패스워드 텍스트박스-------------------------------
                          controller: passwordInputController,
                          focusNode: widget.textPasswordFocus,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(128, 255, 255, 255),
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ]),
                    ),
                  ),
                  Spacer(flex: 2),
                  //Login 버튼--------------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 127, 116, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailInputController.text,
                              password: passwordInputController.text,
                            );
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/ask_page');
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text("User not found"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Close"))
                                    ],
                                  );
                                },
                              );
                            } else if (e.code == 'wrong-password') {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text("Wrong password"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Close"))
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: 'montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  //회원가입 버튼------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New user?",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'montserrat',
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign_up_page');
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color.fromARGB(255, 127, 116, 255),
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(flex: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
