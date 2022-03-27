import 'package:ask_it/session_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final textsInputController = TextEditingController();

class ScratchPad extends StatefulWidget {
  ScratchPad({Key? key}) : super(key: key);

  @override
  State<ScratchPad> createState() => _ScratchPadState();
}

//
//내 메모 입력
Future writeScratch(String docId, String texts) async {
  await FirebaseFirestore.instance
      .collection('DiscussPage_Sessions')
      .doc(docId)
      .collection('ScratchPad')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .set({
        'texts': texts,
      })
      .then((value) => print("Set"))
      .catchError((error) => print("Failed to add user: $error"));
}

//내 메모 불러오기
Future<String> getScratch(String docId) async {
  DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('DiscussPage_Sessions')
      .doc(docId)
      .collection('ScratchPad')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get();

  if (!snapshot.exists) {
    writeScratch(docId, "");

    return "";
  }

  return snapshot.get("texts");
}

class _ScratchPadState extends State<ScratchPad> {
  bool update = false;
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: Column(
            children: [
              //상단바 div
              Container(
                height: 70,
                child: Row(
                  children: [
                    //뒤로가기 버튼
                    IconButton(
                      padding: EdgeInsets.all(20),
                      onPressed: () async {
                        await writeScratch(args["docId"], textsInputController.text);
                        Navigator.pop(context);
                        textsInputController.clear();
                      },
                      iconSize: 35,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Scratch Pad",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: getScratch(args["docId"]),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData == false) {
                        return Container(
                          child: Text(
                            "Loading",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Montserrat",
                            ),
                          ),
                        );
                      } else {
                        print(update);
                        if (update == false) {
                          textsInputController.text = snapshot.data;
                          update = true;
                        }
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextFormField(
                            // focusNode: questionFocus,
                            controller: textsInputController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: "Montserrat",
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write your question here.",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(140, 255, 255, 255),
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
