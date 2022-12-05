import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:tflite_image_classification/HerbalJsonModel.dart';
import 'package:flutter/services.dart' as rootBundle;

class HerbList extends StatefulWidget {
  const HerbList({Key? key}) : super(key: key);

  @override
  State<HerbList> createState() => _HerbListState();
}

class _HerbListState extends State<HerbList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            width: 70,
            child: Image.asset('assets/Ciceley.png'),
          ),
          backgroundColor: const Color.fromARGB(255, 13, 19, 12),
        ),
        body: FutureBuilder(
          future: ReadJsonData(),
          builder: (context, data) {
            if (data.hasError) {
              //in case if error found
              return Center(child: Text("${data.error}"));
            } else if (data.hasData) {
              //once data is ready this else block will execute
              // items will hold all the data of DataModel
              //items[index].name can be used to fetch name of product as done below
              var items = data.data as List<HerbalJsonModel>;
              return ListView.builder(
                  itemCount: items == null ? 0 : items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              child: Image(
                                image: NetworkImage(
                                    items[index].imageURL.toString()),
                                fit: BoxFit.fill,
                              ),
                            ),
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Text(
                                      items[index].plantName.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child:
                                        Text(items[index].scienName.toString()),
                                  ),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              // show circular progress while data is getting fetched from json file
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  Future<List<HerbalJsonModel>> ReadJsonData() async {
    final jsondata = await rootBundle.rootBundle.loadString('assets/list.json');
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => HerbalJsonModel.fromJson(e)).toList();
  }
}
