import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late File _image;
  List? _results;
  final _items = [];
  var items;
  var plantName, description, uses, scienName, location;
  int _selectedIndex = 0;

  bool imageSelect = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> readJson(res) async {
    final String response =
        await rootBundle.loadString('assets/model_desc.json');
    final data = await json.decode(response);
    Map myMap = await json.decode(response);

    final desc = res[0]['index'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman-Gamot"),
      ),
      body: ListView(
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Center(
                      child: Text("No image selected"),
                    ),
                  ),
                ),
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              if (_results != null)
                Text(
                  '${_results![0]["label"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                )
              else
                Container()
            ],
          ),
          if (_results != null) Text("$plantName"),
          if (_results != null) Text("$scienName"),
          if (_results != null) Text("$description"),
          if (_results != null) Text("$location"),
          if (_results != null) Text("$uses"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Pick Image',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          switch (index) {
            case 0:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                getImage();
              }
              break;
            case 1:
              pickImage();
              break;
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
      /*    floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        FloatingActionButton(
          heroTag: "btn1",
          onPressed: getImage,
          tooltip: "Take Image",
          backgroundColor: Colors.greenAccent,
          child: const Icon(Icons.camera),
        ),
        FloatingActionButton(
          heroTag: "btn2",
          onPressed: pickImage,
          tooltip: "Pick Image",
          backgroundColor: Colors.greenAccent,
          child: const Icon(Icons.image),
        ),
      ]), */
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!.path);
    });
    imageClassification(_image);
  }
}
