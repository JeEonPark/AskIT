import 'package:ask_it/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
  FocusNode textEmailFocus = FocusNode();
  FocusNode textPasswordFocus = FocusNode();
  FocusNode textConfirmPasswordFocus = FocusNode();
  FocusNode textUsernameFocus = FocusNode();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final password2InputController = TextEditingController();
  final usernameInputController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          widget.textEmailFocus.unfocus();
          widget.textPasswordFocus.unfocus();
          widget.textConfirmPasswordFocus.unfocus();
          widget.textUsernameFocus.unfocus();
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 29, 30, 37),
          body: SafeArea(
            //전체 박스 감싸는 div-------------------------------------------
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 4),
                  //Sign Up 로고 박스----------------------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                  //sign Up 글 박스----------------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: const Text(
                        "Please enter your information",
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
                  //Email Pw 인풋 창-----------------------------------------------
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      child: Column(children: [
                        TextFormField(
                          //이메일 텍스트박스----------------------------
                          controller: emailInputController,
                          focusNode: widget.textEmailFocus,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
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
                          //패스워드 텍스트박스---------------------------------
                          controller: passwordInputController,
                          focusNode: widget.textPasswordFocus,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
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
                        SizedBox(height: 7),
                        TextFormField(
                          //패스워드 확인 텍스트박스--------------------------------
                          controller: password2InputController,
                          focusNode: widget.textConfirmPasswordFocus,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Confirm Password",
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
                          //유저네임 텍스트박스--------------------------------
                          controller: usernameInputController,
                          focusNode: widget.textUsernameFocus,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Username",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(128, 255, 255, 255),
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  Spacer(flex: 2),
                  //Sign Up 버튼--------------------------------------------------
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
                          if (passwordInputController.text !=
                              password2InputController.text) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text("Please check Password again!"),
                                );
                              },
                            );
                          } else {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: emailInputController.text,
                                password: passwordInputController.text,
                              );
                              firestore
                                  .collection('UserInformation')
                                  .doc(emailInputController.text)
                                  .set({
                                    'email': emailInputController.text,
                                    'username': usernameInputController.text,
                                  })
                                  .then((value) => print("User Added"))
                                  .catchError((error) =>
                                      print("Failed to add user: $error"));
                              String username = usernameInputController.text;
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text("Welcome! $username!"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text("Let's go sign in!"))
                                    ],
                                  );
                                },
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'email-already-in-use') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content: Text("Email already exist!"),
                                    );
                                  },
                                );
                              } else if (e.code == 'invalid-email') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content: Text("Invalid Email!"),
                                    );
                                  },
                                );
                              } else if (e.code == 'weak-password') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content:
                                          Text("The password is too weak!"),
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontFamily: 'montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  //로그인으로 되돌아가기 버튼--------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'montserrat',
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Color.fromARGB(255, 127, 116, 255),
                            fontFamily: 'montserrat',
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
