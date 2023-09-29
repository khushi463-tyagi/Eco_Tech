import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  //Sign out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Uint8List webImage = Uint8List(8);
  final picker = ImagePicker();
  Uint8List? registrationImage;
  late Stopwatch stopwatch;
  late Timer t;
  bool _loading = false;
  List _output = [];

  void handleStartStop() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
    } else {
      stopwatch.start();
    }
  }

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;

    String milliseconds = (milli % 1000).toString().padLeft(3, "0");
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");

    return "$minutes:$seconds:$milliseconds";
  }

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();

    t = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
      loadModel().then((value) {
        setState(() {});
      });
    });
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output is List<Map<String, dynamic>>) {
      setState(() {
        _output = output;
        _loading = false;
      });
    } else {
      print('Invalid output format: $output');
      // Handle the case where _output is not populated correctly.
      // You can reset _output or set it to a default value here.
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List?> galleryImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null)
      return await file.readAsBytes(); // convert into Uint8List.
    return null;
  }

  Future<Uint8List?> cameraImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (file != null)
      return await file.readAsBytes(); // convert into Uint8List.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'GreenTrekker',
            ),
          ),
          backgroundColor: Colors.teal[500],
        ),
        backgroundColor: Colors.teal[100],
        body: SafeArea(
            child: Row(
          children: [
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(250, 30, 50, 10),
                  child: Text(
                    'Lets Start Plogging',
                    style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(250, 20, 50, 10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: CupertinoButton(
                          onPressed: () {
                            handleStartStop();
                          },
                          padding: const EdgeInsets.all(0),
                          child: Container(
                            height: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.teal,
                                width: 15,
                              ),
                            ),
                            child: Text(
                              returnFormattedText(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(30),
                        child: CupertinoButton(
                          onPressed: () {
                            stopwatch.reset();
                          },
                          padding: const EdgeInsets.all(0),
                          child: const Text(
                            "Reset",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Column(
              children: <Widget>[
                SizedBox(
                  width: 500.0,
                  height: 300.0,
                  child: registrationImage != null
                      ? Container(
                          child: Column(
                            children: [
                              Container(
                                child: Image.memory(registrationImage!),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                child: Text(
                                  'It is a Trash',
                                  style: const TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
                if (_output.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(200, 20, 20, 10),
                    child: Text(
                      '${_output[0]['label']}',
                      style: const TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.fromLTRB(300, 20, 20, 10),
                    child: Text(
                      '',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 15,
                      ),
                    ),
                  ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(300, 20, 10, 10),
                        child: GestureDetector(
                          onTap: () async {
                            final Uint8List? image = await cameraImagePicker();
                            if (image != null) {
                              registrationImage = image;
                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Capture a photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.fromLTRB(300, 20, 10, 20),
                        child: GestureDetector(
                          onTap: () async {
                            final Uint8List? image = await galleryImagePicker();
                          },
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Select a photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
