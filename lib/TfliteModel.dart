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

    print(_results);

    readJson(_results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* leading: Image.asset('assets/CiceleyLogo.png'),
        leadingWidth: 30, */
        /* leading: Container(
          width: 20,
          height: 20,
          child: Image.asset('assets/CiceleyLogo.png'),
        ), */
        title: Container(
          width: 70,
          child: Image.asset('assets/Ciceley.png'),
        ),
        /* title: const Text("Ciceley"), */
        backgroundColor: Color.fromARGB(255, 13, 19, 12),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(19),
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
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
              if (_results != null)
                Text(
                  '${_results![0]["label"]}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 25.0,
                  ),
                )
              else
                Container()
            ],
          ),
          if (_results != null)
            Text(
              'Herb: $plantName',
              style:
                  TextStyle(color: Color.fromARGB(255, 18, 1, 1), fontSize: 15),
            ),
          if (_results != null)
            Text(
              'Scientific name: $scienName',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
            ),
          if (_results != null)
            Text(
              'Description: $description',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
            ),
          if (_results != null)
            Text(
              'Where can it be found: $location',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
            ),
          if (_results != null)
            Text(
              'What are its uses: $uses',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
            ),
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
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
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
          backgroundColor: Color.fromARGB(255, 0, 20, 10),
          child: const Icon(Icons.camera),
        ),
        FloatingActionButton(
          heroTag: "btn2",
          onPressed: pickImage,
          tooltip: "Pick Image",
          backgroundColor: Color.fromARGB(255, 0, 20, 10),
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
