import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_image_classification/Listviewherb.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  FlutterTts flutterTts = FlutterTts();

  late File _image;
  List? _results;
  final _items = [];
  var items;
  var plantName, description, uses, scienName, location;
  double percentage = 0.00;
  int _selectedIndex = 0;
  final photos = <File>[];
  bool speaking = false;

  bool imageSelect = false;
  @override
  void initState() {
    super.initState();
    loadModel();
    File image = File(widget.picture.path);

    imageClassification(image);

    flutterTts.setStartHandler(() {
      ///This is called when the audio starts
      setState(() {
        speaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      ///This is called when the audio ends
      setState(() {
        speaking = false;
      });
    });

    flutterTts.setErrorHandler((err) {
      setState(() {
        speaking = false;
      });
    });
  }

  Future<void> readJson(res) async {
    final String response =
        await rootBundle.loadString('assets/model_desc.json');
    final data = await json.decode(response);
    Map myMap = await json.decode(response);

    final desc = res[0]['index'];
    percentage = res[0]['confidence'];
    //print(myMap);

    myMap.forEach((key, value) {
      items = (value[desc]);
      plantName = (value[desc]['plantName']);
      scienName = (value[desc]['scienName']);
      description = (value[desc]['description']);
      location = (value[desc]['location']);
      uses = (value[desc]['uses']);
    });

    setState(() {});
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt"))!;
    //print("Models loading status: $res");
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _results = recognitions!;
      _image = image;

      imageSelect = true;
    });

    readJson(_results);
  }

  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);

    var result = await flutterTts.speak(text);

    if (result == 1) {
      setState(() {
        speaking = true;
      });
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        speaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HerbList()),
                  );
                },
                child: const Icon(Icons.menu_book_rounded),
              )),
        ],
        title: Container(
          width: 70,
          child: Image.asset('assets/Ciceley.png'),
        ),
        /* title: const Text("Ciceley"), */
        backgroundColor: const Color.fromARGB(255, 13, 19, 12),
      ),
      body:
          /* Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250) */

          ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(19),
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(File(widget.picture.path),
                      fit: BoxFit.scaleDown, width: 250),
                )
              : Container(
                  margin: const EdgeInsets.all(20),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Center(
                      child: Text("Please select an image"),
                    ),
                  ),
                ),
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              if (_results != null && percentage > 0.50)
                Text(
                  '${_results![0]["label"]}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 25.0,
                  ),
                ),
              if (_results != null && percentage > 0.50)
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          //speechSettings1();
                          speaking ? _stop() : speak(description);
                        });
                      },
                      child: speaking
                          ? const Icon(
                              Icons.stop,
                            )
                          : const Icon(
                              Icons.play_arrow,
                            ),
                    )),
              if (_results != null && percentage < 0.50)
                const Text(
                  'The selected image cannot be recognized by the application as an herb or must be at least 50% local herb. Please select image of an herb',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
                )
              else
                Container()
            ],
          ),
          if (_results != null && percentage > 0.50)
            Container(
              alignment: Alignment.center,
              child: Text(
                'Herb: $plantName'
                '\n'
                'Scientific name: $scienName'
                '\n\n'
                'Description: $description'
                '\n\n'
                'Where can it be found: $location'
                '\n\n'
                'What are its uses: $uses',
                style: const TextStyle(
                    color: Color.fromARGB(255, 18, 1, 1), fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }
}
