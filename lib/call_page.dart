import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  CallPage({Key? key}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5)),
                child: Icon(Icons.person_outline, color: Colors.white, size: 70),
              ),
              Text(
                args["username"],
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat",
                  color: Colors.white,
                ),
              ),
              Text(
                "00 : 02",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Montserrat",
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.volume_up_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        "speaker",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.close_fullscreen_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        "hide",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.mic_off_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        "mute",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(
                      color: Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.call_end_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
