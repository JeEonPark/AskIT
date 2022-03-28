import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionSettingPage extends StatefulWidget {
  SessionSettingPage({Key? key}) : super(key: key);

  @override
  State<SessionSettingPage> createState() => _SessionSettingPageState();
}

//글 지우기
void deleteSession(String docId) async {
  print(docId);
  FirebaseFirestore.instance
      .collection("DiscussPage_Sessions")
      .doc(docId)
      .delete()
      .then((value) => print("success"))
      .catchError((error) => print("Failed to add user: $error"));
}

class _SessionSettingPageState extends State<SessionSettingPage> {
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
              //상단바 영역
              Container(
                height: 70,
                child: Row(
                  children: [
                    //뒤로가기 버튼
                    IconButton(
                      padding: EdgeInsets.all(20),
                      onPressed: () {
                        Navigator.pop(this.context);
                      },
                      iconSize: 35,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Session Settings",
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
              SizedBox(height: 100),
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 28,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {},
                      label: Text(
                        "Edit contents",
                        style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.update_outlined,
                        size: 28,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {},
                      label: Text(
                        "Change period",
                        style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        size: 28,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text("Do you want to delete Session?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteSession(args['docId']);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Yes, Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: Text(
                        "Delete session",
                        style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
